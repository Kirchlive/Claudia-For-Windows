// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod checkpoint;
mod claude_binary;
mod commands;
mod process;

use checkpoint::state::CheckpointState;
use commands::agents::{
    cleanup_finished_processes, create_agent, delete_agent, execute_agent, export_agent,
    export_agent_to_file, fetch_github_agent_content, fetch_github_agents, get_agent,
    get_agent_run, get_agent_run_with_real_time_metrics, get_claude_binary_path,
    get_live_session_output, get_session_output, get_session_status, import_agent,
    import_agent_from_file, import_agent_from_github, init_database, kill_agent_session,
    list_agent_runs, list_agent_runs_with_metrics, list_agents, list_claude_installations,
    list_running_sessions, set_claude_binary_path, stream_session_output, update_agent, AgentDb,
};
use commands::claude::{
    cancel_claude_execution, check_auto_checkpoint, check_claude_version, cleanup_old_checkpoints,
    clear_checkpoint_manager, continue_claude_code, create_checkpoint, execute_claude_code,
    find_claude_md_files, fork_from_checkpoint, get_checkpoint_diff, get_checkpoint_settings,
    get_checkpoint_state_stats, get_claude_session_output, get_claude_settings, get_project_sessions,
    get_recently_modified_files, get_session_timeline, get_system_prompt, list_checkpoints,
    list_directory_contents, list_projects, list_running_claude_sessions, load_session_history,
    open_new_session, read_claude_md_file, restore_checkpoint, resume_claude_code,
    save_claude_md_file, save_claude_settings, save_system_prompt, search_files,
    track_checkpoint_message, track_session_messages, update_checkpoint_settings,
    ClaudeProcessState,
};
use commands::mcp::{
    mcp_add, mcp_add_from_claude_desktop, mcp_add_json, mcp_get, mcp_get_server_status, mcp_list,
    mcp_read_project_config, mcp_remove, mcp_reset_project_choices, mcp_save_project_config,
    mcp_serve, mcp_test_connection,
};

use commands::usage::{
    get_session_stats, get_usage_by_date_range, get_usage_details, get_usage_stats,
};
use process::ProcessRegistryState;
use std::sync::Mutex;
use tauri::Manager;
use std::process::Command;

fn main() {
    // Initialize logger
    env_logger::init();

    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .setup(|app| {
            // Check Claude CLI version
            let claude_path = match std::env::var("CLAUDIE_CLI_PATH") {
                Ok(val) => val,
                Err(_) => "claude".to_string(),
            };

            let claude_version_output = Command::new(&claude_path)
                .arg("--version")
                .output();

            if let Ok(output) = claude_version_output {
                let claude_version = if output.status.success() {
                    String::from_utf8_lossy(&output.stdout).trim().to_string()
                } else {
                    "unknown".to_string()
                };

                // Accept multiple versions - check if it contains valid version pattern
                // This accepts any version that contains "Claude Code" or has a version number format
                let is_valid_version = claude_version.contains("Claude Code") || 
                                     claude_version.chars().any(|c| c.is_digit(10)) && claude_version.contains('.');
                
                if claude_version == "unknown" || !is_valid_version {
                    let window = app.get_webview_window("main");
                    if let Some(window) = window {
                        let message = format!(
                            "Claude CLI version is not compatible. Found version: {}, expected Claude Code x.x.x format. Please check your Claude CLI installation.",
                            claude_version
                        );
                        // Show a dialog to the user using tauri_plugin_dialog
                        tauri::async_runtime::spawn(async move {
                            use tauri_plugin_dialog::DialogExt;
                            window.dialog()
                                .message(message)
                                .title("Version Mismatch")
                                .blocking_show();
                        });
                    }
                }
            }

            // Initialize agents database
            let conn = init_database(&app.handle()).expect("Failed to initialize agents database");
            app.manage(AgentDb(Mutex::new(conn)));

            // Initialize checkpoint state
            let checkpoint_state = CheckpointState::new();

            // Set the Claude directory path
            if let Ok(claude_dir) = dirs::home_dir()
                .ok_or_else(|| "Could not find home directory")
                .and_then(|home| {
                    let claude_path = home.join(".claude");
                    claude_path
                        .canonicalize()
                        .map_err(|_| "Could not find ~/.claude directory")
                })
            {
                let state_clone = checkpoint_state.clone();
                tauri::async_runtime::spawn(async move {
                    state_clone.set_claude_dir(claude_dir).await;
                });
            }

            app.manage(checkpoint_state);

            // Initialize process registry
            app.manage(ProcessRegistryState::default());

            // Initialize Claude process state
            app.manage(ClaudeProcessState::default());

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            list_projects,
            get_project_sessions,
            get_claude_settings,
            open_new_session,
            get_system_prompt,
            check_claude_version,
            save_system_prompt,
            save_claude_settings,
            find_claude_md_files,
            read_claude_md_file,
            save_claude_md_file,
            load_session_history,
            execute_claude_code,
            continue_claude_code,
            resume_claude_code,
            cancel_claude_execution,
            list_running_claude_sessions,
            get_claude_session_output,
            list_directory_contents,
            search_files,
            create_checkpoint,
            restore_checkpoint,
            list_checkpoints,
            fork_from_checkpoint,
            get_session_timeline,
            update_checkpoint_settings,
            get_checkpoint_diff,
            track_checkpoint_message,
            track_session_messages,
            check_auto_checkpoint,
            cleanup_old_checkpoints,
            get_checkpoint_settings,
            clear_checkpoint_manager,
            get_checkpoint_state_stats,
            get_recently_modified_files,
            list_agents,
            create_agent,
            update_agent,
            delete_agent,
            get_agent,
            execute_agent,
            list_agent_runs,
            get_agent_run,
            list_agent_runs_with_metrics,
            get_agent_run_with_real_time_metrics,
            list_running_sessions,
            kill_agent_session,
            get_session_status,
            cleanup_finished_processes,
            get_session_output,
            get_live_session_output,
            stream_session_output,
            get_claude_binary_path,
            set_claude_binary_path,
            list_claude_installations,
            export_agent,
            export_agent_to_file,
            import_agent,
            import_agent_from_file,
            fetch_github_agents,
            fetch_github_agent_content,
            import_agent_from_github,
            get_usage_stats,
            get_usage_by_date_range,
            get_usage_details,
            get_session_stats,
            mcp_add,
            mcp_list,
            mcp_get,
            mcp_remove,
            mcp_add_json,
            mcp_add_from_claude_desktop,
            mcp_serve,
            mcp_test_connection,
            mcp_reset_project_choices,
            mcp_get_server_status,
            mcp_read_project_config,
            mcp_save_project_config
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}