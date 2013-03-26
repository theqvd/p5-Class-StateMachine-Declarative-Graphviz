%state_machines = (
                    'QVD::HKD::ClusterMonitor' => [
                                                    'new',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run' => 'long_delaying'
                                                                       }
                                                    },
                                                    'killing_hosts',
                                                    {
                                                      'transitions' => {
                                                                         '_on_kill_hosts_error' => 'unassigning_vms',
                                                                         '_on_kill_hosts_done' => 'unassigning_vms'
                                                                       },
                                                      'enter' => '_kill_hosts'
                                                    },
                                                    'unassigning_vms',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unassign_vms_done' => 'unassigning_l7rs',
                                                                         '_on_unassign_vms_error' => 'unassigning_l7rs'
                                                                       },
                                                      'enter' => '_unassign_vms'
                                                    },
                                                    'unassigning_l7rs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unassign_l7rs_error' => 'aborting_l7rs',
                                                                         '_on_unassign_l7rs_done' => 'aborting_l7rs'
                                                                       },
                                                      'enter' => '_unassign_l7rs'
                                                    },
                                                    'aborting_l7rs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_abort_l7rs_done' => 'notifying_hkds',
                                                                         '_on_abort_l7rs_error' => 'idle'
                                                                       },
                                                      'enter' => '_abort_l7rs'
                                                    },
                                                    'notifying_hkds',
                                                    {
                                                      'transitions' => {
                                                                         '_on_notify_hkds_error' => 'idle',
                                                                         '_on_notify_hkds_done' => 'idle'
                                                                       },
                                                      'enter' => '_notify_hkds'
                                                    },
                                                    'idle',
                                                    {
                                                      'transitions' => {
                                                                         'on_hkd_stop' => 'stopped',
                                                                         '_on_timeout' => 'killing_hosts'
                                                                       },
                                                      'enter' => '_set_timer'
                                                    },
                                                    'long_delaying',
                                                    {
                                                      'transitions' => {
                                                                         'on_hkd_stop' => 'stopped',
                                                                         '_on_timeout' => 'killing_hosts'
                                                                       },
                                                      'enter' => '_set_timer'
                                                    },
                                                    'stopped',
                                                    {
                                                      'enter' => '_on_stopped'
                                                    },
                                                    '__any__',
                                                    {
                                                      'leave' => '_abort_all',
                                                      'transitions' => {
                                                                         'on_transient_db_error' => 'long_delaying'
                                                                       },
                                                      'delay_once' => [
                                                                        'on_hkd_stop'
                                                                      ]
                                                    }
                                                  ],
                    'QVD::HKD::Ticker' => [
                                            'new',
                                            {
                                              'transitions' => {
                                                                 '_on_run' => 'ticking'
                                                               }
                                            },
                                            'ticking',
                                            {
                                              'transitions' => {
                                                                 '_on_delay' => 'delaying'
                                                               },
                                              'enter' => '_tick'
                                            },
                                            'delaying',
                                            {
                                              'leave' => '_abort_all',
                                              'transitions' => {
                                                                 'on_hkd_stop' => 'stopped',
                                                                 '_on_timeout' => 'ticking'
                                                               },
                                              'enter' => '_set_timer'
                                            },
                                            'stopped',
                                            {
                                              'enter' => '_on_stopped'
                                            }
                                          ],
                    'QVD::HKD::L7RKiller' => [
                                               'new',
                                               {
                                                 'transitions' => {
                                                                    '_on_run' => 'idle'
                                                                  }
                                               },
                                               'getting_user_cmd',
                                               {
                                                 'transitions' => {
                                                                    '_on_get_user_cmd_error' => 'idle',
                                                                    '_on_get_user_cmd_done' => 'killing_l7r'
                                                                  },
                                                 'enter' => '_get_user_cmd'
                                               },
                                               'killing_l7r',
                                               {
                                                 'transitions' => {
                                                                    '_on_kill_l7r_error' => 'getting_user_cmd',
                                                                    '_on_kill_l7r_done' => 'getting_user_cmd'
                                                                  },
                                                 'enter' => '_kill_l7r'
                                               },
                                               'idle',
                                               {
                                                 'transitions' => {
                                                                    '_on_qvd_cmd_for_user_notify' => 'getting_user_cmd',
                                                                    'on_hkd_stop' => 'stopped',
                                                                    '_on_timeout' => 'getting_user_cmd'
                                                                  },
                                                 'leave' => '_abort_call_after',
                                                 'enter' => '_set_timer'
                                               },
                                               'stopped',
                                               {
                                                 'enter' => '_on_stopped'
                                               },
                                               '__any__',
                                               {
                                                 'delay_once' => [
                                                                   '_on_qvd_cmd_for_user_notify',
                                                                   '_on_hkd_stop'
                                                                 ]
                                               }
                                             ],
                    'QVD::HKD::DHCPDHandler' => [
                                                  'new',
                                                  {
                                                    'transitions' => {
                                                                       '_on_run' => 'running'
                                                                     }
                                                  },
                                                  'running',
                                                  {
                                                    'transitions' => {
                                                                       'on_hkd_stop' => 'stopping'
                                                                     },
                                                    'enter' => '_run_dhcpd'
                                                  },
                                                  'stopping',
                                                  {
                                                    'ignore' => [
                                                                  'on_hkd_stop'
                                                                ],
                                                    'transitions' => {
                                                                       '_on_run_dhcpd_done' => 'stopped'
                                                                     },
                                                    'enter' => '_kill_cmd'
                                                  },
                                                  'stopped',
                                                  {
                                                    'enter' => '_on_stopped'
                                                  }
                                                ],
                    'QVD::HKD::Config' => [
                                            'idle',
                                            {
                                              'transitions' => {
                                                                 '_on_qvd_config_changed_notify' => 'reloading'
                                                               }
                                            },
                                            'reloading',
                                            {
                                              'delay' => [
                                                           '_on_qvd_config_changed_notify'
                                                         ],
                                              'transitions' => {
                                                                 '_goto_idle' => 'idle'
                                                               },
                                              'enter' => '_reload'
                                            }
                                          ],
                    'QVD::HKD::VMCommandHandler' => [
                                                      'new',
                                                      {
                                                        'transitions' => {
                                                                           '_on_run' => 'idle'
                                                                         }
                                                      },
                                                      'idle',
                                                      {
                                                        'transitions' => {
                                                                           '_on_qvd_cmd_for_vm_notify' => 'loading_cmd',
                                                                           '_on_delete_cmd' => 'deleting_cmds',
                                                                           'on_hkd_stop' => 'stopped',
                                                                           '_on_timeout' => 'loading_cmd'
                                                                         },
                                                        'leave' => '_abort_call_after',
                                                        'enter' => '_set_timer'
                                                      },
                                                      'loading_cmd',
                                                      {
                                                        'transitions' => {
                                                                           '_on_cmd_not_found' => 'deleting_cmds',
                                                                           '_on_load_cmd_error' => 'idle',
                                                                           '_on_cmd_loaded' => 'locking_cmd'
                                                                         },
                                                        'enter' => '_load_cmd'
                                                      },
                                                      'locking_cmd',
                                                      {
                                                        'transitions' => {
                                                                           '_on_lock_cmd_done' => 'delivering_cmd',
                                                                           '_on_lock_cmd_error' => 'idle'
                                                                         },
                                                        'enter' => '_lock_cmd'
                                                      },
                                                      'delivering_cmd',
                                                      {
                                                        'transitions' => {
                                                                           '_on_deliver_cmd_done' => 'loading_cmd'
                                                                         },
                                                        'enter' => '_deliver_cmd'
                                                      },
                                                      'deleting_cmds',
                                                      {
                                                        'transitions' => {
                                                                           '_on_delete_cmds_done' => 'idle',
                                                                           '_on_delete_cmds_error' => 'idle'
                                                                         },
                                                        'enter' => '_delete_cmds'
                                                      },
                                                      'stopped',
                                                      {
                                                        'enter' => '_on_stopped'
                                                      },
                                                      '__any__',
                                                      {
                                                        'delay_once' => [
                                                                          '_on_delete_cmd',
                                                                          '_on_qvd_cmd_for_vm_notify',
                                                                          'on_hkd_stop'
                                                                        ]
                                                      }
                                                    ],
                    'QVD::HKD::VMHandler::KVM' => [
                                                    'new',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_catch_zombie' => 'zombie/beating_to_death',
                                                                         '_on_cmd_start' => 'starting'
                                                                       }
                                                    },
                                                    'starting',
                                                    {
                                                      'jump' => 'starting/saving_state'
                                                    },
                                                    'starting/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_done' => 'starting/loading_row'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'starting/loading_row',
                                                    {
                                                      'transitions' => {
                                                                         '_on_load_row_done' => 'starting/updating_stats',
                                                                         '_on_load_row_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_load_row'
                                                    },
                                                    'starting/updating_stats',
                                                    {
                                                      'transitions' => {
                                                                         '_on_incr_run_attempts_done' => 'starting/searching_di',
                                                                         '_on_incr_run_attempts_bad_result' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_incr_run_attempts'
                                                    },
                                                    'starting/searching_di',
                                                    {
                                                      'transitions' => {
                                                                         '_on_search_di_error' => 'stopping/clearing_runtime_row',
                                                                         '_on_search_di_done' => 'starting/saving_runtime_row'
                                                                       },
                                                      'enter' => '_search_di'
                                                    },
                                                    'starting/saving_runtime_row',
                                                    {
                                                      'ignore' => [
                                                                    '_on_save_runtime_row_result'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_save_runtime_row_error' => 'stopping/clearing_runtime_row',
                                                                         '_on_save_runtime_row_done' => 'starting/deleting_cmd'
                                                                       },
                                                      'enter' => '_save_runtime_row'
                                                    },
                                                    'starting/deleting_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_delete_cmd_error' => 'starting/calculating_attrs',
                                                                         '_on_delete_cmd_done' => 'starting/calculating_attrs'
                                                                       },
                                                      'enter' => '_delete_cmd'
                                                    },
                                                    'starting/calculating_attrs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_calculate_attrs_done' => 'starting/setting_heavy_mark'
                                                                       },
                                                      'enter' => '_calculate_attrs'
                                                    },
                                                    'starting/setting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_heavy_mark_error' => 'starting/delaying',
                                                                         '_on_set_heavy_mark_done' => 'starting/allocating_os_disk'
                                                                       },
                                                      'enter' => '_set_heavy_mark'
                                                    },
                                                    'starting/delaying',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_go_heavy' => 'starting/setting_heavy_mark'
                                                                       }
                                                    },
                                                    'starting/allocating_os_disk',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_os_disk_done' => 'starting/allocating_user_disk',
                                                                         '_on_allocate_os_disk_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_allocate_os_disk'
                                                    },
                                                    'starting/allocating_user_disk',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_user_disk_error' => 'stopping/clearing_runtime_row',
                                                                         '_on_allocate_user_disk_done' => 'starting/removing_old_fw_rules'
                                                                       },
                                                      'enter' => '_allocate_user_disk'
                                                    },
                                                    'starting/removing_old_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'starting/allocating_tap',
                                                                         '_on_remove_fw_rules_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'starting/allocating_tap',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_tap_done' => 'starting/running_prestart_hook',
                                                                         '_on_allocate_tap_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_allocate_tap'
                                                    },
                                                    'starting/running_prestart_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'starting/setting_fw_rules',
                                                                         '_on_run_hook_error' => 'stopping/saving_state_2'
                                                                       },
                                                      'enter' => '_run_prestart_hook'
                                                    },
                                                    'starting/setting_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_fw_rules_error' => 'stopping/saving_state_2',
                                                                         '_on_set_fw_rules_done' => 'starting/enabling_iface'
                                                                       },
                                                      'enter' => '_set_fw_rules'
                                                    },
                                                    'starting/enabling_iface',
                                                    {
                                                      'transitions' => {
                                                                         '_on_enable_iface_error' => 'stopping/saving_state_2',
                                                                         '_on_enable_iface_done' => 'starting/launching'
                                                                       },
                                                      'enter' => '_enable_iface'
                                                    },
                                                    'starting/launching',
                                                    {
                                                      'transitions' => {
                                                                         '_on_launch_process_done' => 'starting/waiting_for_vma',
                                                                         '_on_launch_process_error' => 'stopping/saving_state_2'
                                                                       },
                                                      'enter' => '_launch_process'
                                                    },
                                                    'starting/waiting_for_vma',
                                                    {
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/saving_state_2',
                                                                         '_on_alive' => 'running/saving_state',
                                                                         'on_hkd_stop' => 'stopping/saving_state',
                                                                         '_on_goto_debug' => 'debugging/saving_state',
                                                                         '_on_dead' => 'stopping/killing_vm'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'running/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/saving_state',
                                                                         '_on_save_state_done' => 'running/updating_stats'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'running/updating_stats',
                                                    {
                                                      'ignore' => [
                                                                    '_on_incr_run_ok_result'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_incr_run_ok_error' => 'running/running_poststart_hook',
                                                                         '_on_incr_run_ok_done' => 'running/running_poststart_hook'
                                                                       },
                                                      'enter' => '_incr_run_ok'
                                                    },
                                                    'running/running_poststart_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'running/unsetting_heavy_mark',
                                                                         '_on_run_hook_error' => 'stopping/saving_state'
                                                                       },
                                                      'enter' => '_run_poststart_hook'
                                                    },
                                                    'running/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'running/monitoring'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'running/monitoring',
                                                    {
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/saving_state_2',
                                                                         '_on_cmd_stop' => 'stopping/deleting_cmd',
                                                                         'on_hkd_stop' => 'stopping/saving_state',
                                                                         '_on_goto_debug' => 'debugging/saving_state',
                                                                         '_on_dead' => 'stopping/saving_state'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'debugging/saving_state',
                                                    {
                                                      'delay' => [
                                                                   '_on_vm_process_done'
                                                                 ],
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/saving_state',
                                                                         '_on_save_state_done' => 'debugging/unsetting_heavy_mark'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'debugging/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'debugging/waiting_for_vma'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'debugging/waiting_for_vma',
                                                    {
                                                      'ignore' => [
                                                                    '_on_dead',
                                                                    '_on_goto_debug'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/saving_state_2',
                                                                         '_on_cmd_stop' => 'stopping/deleting_cmd',
                                                                         '_on_alive' => 'running/saving_state',
                                                                         'on_hkd_stop' => 'stopping/saving_state'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'stopping/deleting_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_delete_cmd_done' => 'stopping/saving_state'
                                                                       },
                                                      'enter' => '_delete_cmd'
                                                    },
                                                    'stopping/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/setting_heavy_mark',
                                                                         '_on_save_state_done' => 'stopping/setting_heavy_mark'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'stopping/setting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_heavy_mark_error' => 'stopping/delaying',
                                                                         '_on_set_heavy_mark_done' => 'stopping/powering_off'
                                                                       },
                                                      'enter' => '_set_heavy_mark'
                                                    },
                                                    'stopping/delaying',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_go_heavy' => 'stopping/setting_heavy_mark'
                                                                       }
                                                    },
                                                    'stopping/powering_off',
                                                    {
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/removing_fw_rules',
                                                                         '_on_rpc_poweroff_result' => 'stopping/waiting_for_vm_to_exit',
                                                                         '_on_rpc_poweroff_error' => 'stopping/killing_vm'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_poweroff'
                                                    },
                                                    'stopping/waiting_for_vm_to_exit',
                                                    {
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/removing_fw_rules',
                                                                         'on_hkd_kill' => 'stopping/killing_vm',
                                                                         '_on_state_timeout' => 'stopping/killing_vm'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_set_state_timer'
                                                    },
                                                    'stopping/killing_vm',
                                                    {
                                                      'ignore' => [
                                                                    'on_hhd_kill'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_vm_process_done' => 'stopping/removing_fw_rules'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_kill_vm'
                                                    },
                                                    'stopping/saving_state_2',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/removing_fw_rules',
                                                                         '_on_save_state_done' => 'stopping/removing_fw_rules'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'stopping/removing_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'stopping/running_poststop_hook',
                                                                         '_on_remove_fw_rules_error' => 'stopping/running_poststop_hook'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'stopping/running_poststop_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'stopping/clearing_runtime_row',
                                                                         '_on_run_hook_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_run_prestart_hook'
                                                    },
                                                    'stopping/clearing_runtime_row',
                                                    {
                                                      'ignore' => [
                                                                    '_on_clear_runtime_row_result',
                                                                    '_on_clear_runtime_row_bad_result'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_clear_runtime_row_done' => 'stopped'
                                                                       },
                                                      'enter' => '_clear_runtime_row'
                                                    },
                                                    'stopped',
                                                    {
                                                      'enter' => '_call_on_stopped'
                                                    },
                                                    'zombie/beating_to_death',
                                                    {
                                                      'jump' => 'zombie/saving_state'
                                                    },
                                                    'zombie/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'zombie/calculating_attrs',
                                                                         '_on_save_state_done' => 'zombie/calculating_attrs'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'zombie/calculating_attrs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_calculate_attrs_done' => 'zombie/removing_fw_rules'
                                                                       },
                                                      'enter' => '_calculate_attrs'
                                                    },
                                                    'zombie/removing_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'zombie/clearing_runtime_row',
                                                                         '_on_remove_fw_rules_error' => 'zombie/unsetting_heavy_mark'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'zombie/clearing_runtime_row',
                                                    {
                                                      'transitions' => {
                                                                         '_on_clear_runtime_row_error' => 'zombie/unsetting_heavy_mark',
                                                                         '_on_clear_runtime_row_done' => 'stopped'
                                                                       },
                                                      'enter' => '_clear_runtime_row'
                                                    },
                                                    'zombie/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'zombie'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'zombie',
                                                    {
                                                      'transitions' => {
                                                                         'on_hkd_stop' => 'stopped',
                                                                         '_on_state_timeout' => 'zombie/removing_fw_rules'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_set_state_timer'
                                                    },
                                                    '__any__',
                                                    {
                                                      'delay_once' => [
                                                                        '_on_cmd_stop',
                                                                        '_on_vm_process_done',
                                                                        'on_hkd_stop',
                                                                        'on_hkd_kill'
                                                                      ]
                                                    }
                                                  ],
                    'QVD::HKD::L7RMonitor' => [
                                                'new',
                                                {
                                                  'transitions' => {
                                                                     '_on_run' => 'searching_dead_l7r'
                                                                   }
                                                },
                                                'searching_dead_l7r',
                                                {
                                                  'transitions' => {
                                                                     '_on_search_dead_l7r_done' => 'cleaning_dead_l7r',
                                                                     '_on_search_dead_l7r_error' => 'idle'
                                                                   },
                                                  'enter' => '_search_dead_l7r'
                                                },
                                                'cleaning_dead_l7r',
                                                {
                                                  'transitions' => {
                                                                     '_on_clean_dead_l7r_done' => 'searching_dead_l7r',
                                                                     '_on_clean_dead_l7r_error' => 'idle'
                                                                   },
                                                  'enter' => '_clean_dead_l7r'
                                                },
                                                'idle',
                                                {
                                                  'transitions' => {
                                                                     'on_hkd_stop' => 'stopped',
                                                                     '_on_timeout' => 'getting_user_cmd'
                                                                   },
                                                  'leave' => '_abort_all',
                                                  'enter' => '_set_timer'
                                                },
                                                'stopped',
                                                {
                                                  'enter' => '_on_stopped'
                                                },
                                                '__any__',
                                                {
                                                  'delay_once' => [
                                                                    'on_hkd_stop'
                                                                  ]
                                                }
                                              ],
                    'QVD::HKD' => [
                                    'new',
                                    {
                                      'transitions' => {
                                                         '_on_run' => 'starting/acquiring_lock'
                                                       }
                                    },
                                    'starting/acquiring_lock',
                                    {
                                      'transitions' => {
                                                         '_on_acquire_lock_error' => 'failed',
                                                         '_on_acquire_lock_done' => 'starting/checking_tcp_ports'
                                                       },
                                      'enter' => '_acquire_lock'
                                    },
                                    'starting/checking_tcp_ports',
                                    {
                                      'transitions' => {
                                                         '_on_check_tcp_ports_error' => 'failed',
                                                         '_on_check_tcp_ports_done' => 'starting/connecting_to_db'
                                                       },
                                      'enter' => '_check_tcp_ports'
                                    },
                                    'starting/connecting_to_db',
                                    {
                                      'transitions' => {
                                                         '_on_dead_db' => 'failed',
                                                         '_on_db_connected' => 'starting/loading_db_config'
                                                       },
                                      'enter' => '_start_db'
                                    },
                                    'starting/loading_db_config',
                                    {
                                      'transitions' => {
                                                         '_on_dead_db' => 'failed',
                                                         '_on_config_reload_error' => 'failed',
                                                         '_on_config_reload_done' => 'starting/loading_host_row'
                                                       },
                                      'enter' => '_start_config'
                                    },
                                    'starting/loading_host_row',
                                    {
                                      'transitions' => {
                                                         '_on_load_host_row_error2' => 'failed',
                                                         '_on_load_host_row_done' => 'starting/saving_state'
                                                       },
                                      'enter' => '_load_host_row'
                                    },
                                    'starting/saving_state',
                                    {
                                      'transitions' => {
                                                         '_on_save_state_error' => 'failed',
                                                         '_on_save_state_done' => 'starting/checking_address'
                                                       },
                                      'enter' => '_save_state'
                                    },
                                    'starting/checking_address',
                                    {
                                      'transitions' => {
                                                         '_on_check_address_error' => 'failed',
                                                         '_on_check_address_done' => 'starting/preparing_storage'
                                                       },
                                      'enter' => '_check_address'
                                    },
                                    'starting/preparing_storage',
                                    {
                                      'transitions' => {
                                                         '_on_prepare_storage_error' => 'failed',
                                                         '_on_prepare_storage_done' => 'starting/removing_old_fw_rules'
                                                       },
                                      'enter' => '_prepare_storage'
                                    },
                                    'starting/removing_old_fw_rules',
                                    {
                                      'transitions' => {
                                                         '_on_remove_fw_rules_done' => 'starting/setting_fw_rules'
                                                       },
                                      'enter' => '_remove_fw_rules'
                                    },
                                    'starting/setting_fw_rules',
                                    {
                                      'transitions' => {
                                                         '_on_set_fw_rules_error' => 'failed',
                                                         '_on_set_fw_rules_done' => 'starting/saving_loadbal_data'
                                                       },
                                      'enter' => '_set_fw_rules'
                                    },
                                    'starting/saving_loadbal_data',
                                    {
                                      'transitions' => {
                                                         '_on_save_loadbal_data_error' => 'stopping/removing_fw_rules',
                                                         '_on_save_loadbal_data_done' => 'starting/ticking'
                                                       },
                                      'enter' => '_save_loadbal_data'
                                    },
                                    'starting/ticking',
                                    {
                                      'transitions' => {
                                                         '_on_ticked' => 'starting/catching_zombies',
                                                         '_on_ticker_error' => 'stopping/removing_fw_rules'
                                                       },
                                      'enter' => '_start_ticking'
                                    },
                                    'starting/catching_zombies',
                                    {
                                      'transitions' => {
                                                         '_on_catch_zombies_error' => 'stopping/removing_fw_rules',
                                                         '_on_catch_zombies_done' => 'starting/agents'
                                                       },
                                      'enter' => '_catch_zombies'
                                    },
                                    'starting/agents',
                                    {
                                      'transitions' => {
                                                         '_on_agents_started' => 'running/saving_state'
                                                       },
                                      'enter' => '_start_agents'
                                    },
                                    'running/saving_state',
                                    {
                                      'transitions' => {
                                                         '_on_save_state_error' => 'stopping/killing_all_vms',
                                                         '_on_save_state_done' => 'running/agents'
                                                       },
                                      'enter' => '_save_state'
                                    },
                                    'running/agents',
                                    {
                                      'transitions' => {
                                                         '_on_start_vm_command_handler_done' => 'running'
                                                       },
                                      'enter' => '_start_vm_command_handler'
                                    },
                                    'running',
                                    {
                                      'transitions' => {
                                                         '_on_dead_db' => 'stopping/killing_all_vms',
                                                         '_on_cmd_stop' => 'stopping',
                                                         '_on_ticker_error' => 'stopping/killing_all_vms'
                                                       }
                                    },
                                    'stopping',
                                    {
                                      'jump' => 'stopping/saving_state'
                                    },
                                    'stopping/saving_state',
                                    {
                                      'transitions' => {
                                                         '_on_save_state_error' => 'stopping/killing_all_vms',
                                                         '_on_save_state_done' => 'stopping/stopping_all_vms'
                                                       },
                                      'enter' => '_save_state'
                                    },
                                    'stopping/stopping_all_vms',
                                    {
                                      'transitions' => {
                                                         '_on_state_timeout' => 'stopping/killing_all_vms',
                                                         '_on_stop_all_vms_done' => 'stopping/stopping_all_agents'
                                                       },
                                      'leave' => '_abort_all',
                                      'enter' => '_stop_all_vms'
                                    },
                                    'stopping/killing_all_vms',
                                    {
                                      'transitions' => {
                                                         '_on_stop_all_vms_done' => 'stopping/stopping_all_agents'
                                                       },
                                      'leave' => '_abort_all',
                                      'enter' => '_kill_all_vms'
                                    },
                                    'stopping/stopping_all_agents',
                                    {
                                      'transitions' => {
                                                         '_on_all_agents_stopped' => 'stopping/removing_fw_rules'
                                                       },
                                      'enter' => '_stop_all_agents'
                                    },
                                    'stopping/removing_fw_rules',
                                    {
                                      'transitions' => {
                                                         '_on_remove_fw_rules_done' => 'stopped/saving_state'
                                                       },
                                      'enter' => '_remove_fw_rules'
                                    },
                                    'stopped/saving_state',
                                    {
                                      'transitions' => {
                                                         '_on_save_state_error' => 'stopped/bye',
                                                         '_on_save_state_done' => 'stopped/bye'
                                                       },
                                      'enter' => '_save_state'
                                    },
                                    'stopped/bye',
                                    {
                                      'enter' => '_say_goodbye'
                                    },
                                    'failed',
                                    {
                                      'enter' => '_say_goodbye'
                                    },
                                    '__any__',
                                    {
                                      'ignore' => [
                                                    '_on_ticked',
                                                    '_on_stop_all_vms_done',
                                                    '_on_transient_db_error',
                                                    '_on_config_reload_done',
                                                    '_on_config_reload_error'
                                                  ],
                                      'delay_once' => [
                                                        '_on_cmd_stop',
                                                        '_on_dead_db',
                                                        '_on_ticker_error'
                                                      ]
                                    }
                                  ],
                    'QVD::HKD::CommandHandler' => [
                                                    'new',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run' => 'idle'
                                                                       }
                                                    },
                                                    'idle',
                                                    {
                                                      'leave' => '_abort_call_after',
                                                      'transitions' => {
                                                                         '_on_qvd_cmd_for_host_notify' => 'loading_cmd',
                                                                         'on_hkd_stop' => 'stopped',
                                                                         '_on_timeout' => 'loading_cmd'
                                                                       },
                                                      'enter' => '_set_timer'
                                                    },
                                                    'loading_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_not_found' => 'idle',
                                                                         '_on_load_cmd_error' => 'idle',
                                                                         '_on_cmd_loaded' => 'delivering_cmd'
                                                                       },
                                                      'enter' => '_load_cmd'
                                                    },
                                                    'delivering_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_deliver_cmd_error' => 'idle',
                                                                         '_on_deliver_cmd_done' => 'loading_cmd'
                                                                       },
                                                      'enter' => '_deliver_cmd'
                                                    },
                                                    'stopped',
                                                    {
                                                      'enter' => '_on_stopped'
                                                    },
                                                    '__any__',
                                                    {
                                                      'delay_once' => [
                                                                        '_on_qvd_cmd_for_host_notify',
                                                                        'on_hkd_stop'
                                                                      ]
                                                    }
                                                  ],
                    'QVD::HKD::VMHandler::LXC' => [
                                                    'new',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_catch_zombie' => 'zombie/beating_to_death',
                                                                         '_on_cmd_start' => 'starting'
                                                                       }
                                                    },
                                                    'starting',
                                                    {
                                                      'jump' => 'starting/saving_state'
                                                    },
                                                    'starting/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopped',
                                                                         '_on_save_state_done' => 'starting/loading_row'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'starting/loading_row',
                                                    {
                                                      'transitions' => {
                                                                         '_on_load_row_done' => 'starting/updating_stats',
                                                                         '_on_load_row_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_load_row'
                                                    },
                                                    'starting/updating_stats',
                                                    {
                                                      'transitions' => {
                                                                         '_on_incr_run_attempts_done' => 'starting/searching_di',
                                                                         '_on_incr_run_attempts_error' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_incr_run_attempts'
                                                    },
                                                    'starting/searching_di',
                                                    {
                                                      'transitions' => {
                                                                         '_on_search_di_error' => 'stopping/clearing_runtime_row',
                                                                         '_on_search_di_done' => 'starting/saving_runtime_row'
                                                                       },
                                                      'enter' => '_search_di'
                                                    },
                                                    'starting/saving_runtime_row',
                                                    {
                                                      'ignore' => [
                                                                    '_on_save_runtime_row_result'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_save_runtime_row_error' => 'stopping/clearing_runtime_row',
                                                                         '_on_save_runtime_row_done' => 'starting/deleting_cmd'
                                                                       },
                                                      'enter' => '_save_runtime_row'
                                                    },
                                                    'starting/deleting_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_delete_cmd_error' => 'starting/calculating_attrs',
                                                                         '_on_delete_cmd_done' => 'starting/calculating_attrs'
                                                                       },
                                                      'enter' => '_delete_cmd'
                                                    },
                                                    'starting/calculating_attrs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_calculate_attrs_done' => 'starting/setting_heavy_mark'
                                                                       },
                                                      'enter' => '_calculate_attrs'
                                                    },
                                                    'starting/setting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_heavy_mark_error' => 'starting/delaying',
                                                                         '_on_set_heavy_mark_done' => 'starting/untaring_os_image'
                                                                       },
                                                      'enter' => '_set_heavy_mark'
                                                    },
                                                    'starting/delaying',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_go_heavy' => 'starting/setting_heavy_mark'
                                                                       }
                                                    },
                                                    'starting/untaring_os_image',
                                                    {
                                                      'transitions' => {
                                                                         '_on_untar_os_image_error' => 'stopping/releasing_untar_lock',
                                                                         '_on_untar_os_image_eagain' => 'starting/delaying_untar_os_image',
                                                                         '_on_untar_os_image_done' => 'starting/placing_os_image'
                                                                       },
                                                      'enter' => '_untar_os_image'
                                                    },
                                                    'starting/delaying_untar_os_image',
                                                    {
                                                      'leave' => '_abort_call_after',
                                                      'transitions' => {
                                                                         'on_hkd_stop' => 'stopping/releasing_untar_lock',
                                                                         '_on_delay_untar_os_image_done' => 'starting/setting_heavy_mark'
                                                                       },
                                                      'enter' => '_delay_untar_os_image'
                                                    },
                                                    'starting/placing_os_image',
                                                    {
                                                      'transitions' => {
                                                                         '_on_place_os_image_done' => 'starting/detecting_os_image_type',
                                                                         '_on_place_os_image_error' => 'stopping/releasing_untar_lock'
                                                                       },
                                                      'enter' => '_place_os_image'
                                                    },
                                                    'starting/detecting_os_image_type',
                                                    {
                                                      'transitions' => {
                                                                         '_on_detect_os_image_type_error' => 'stopping/releasing_untar_lock',
                                                                         '_on_detect_os_image_type_done' => 'starting/killing_old_lxc'
                                                                       },
                                                      'enter' => '_detect_os_image_type'
                                                    },
                                                    'starting/killing_old_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_kill_lxc_done' => 'starting/unlinking_iface',
                                                                         '_on_kill_lxc_error' => 'zombie/beating_to_death'
                                                                       },
                                                      'enter' => '_kill_lxc'
                                                    },
                                                    'starting/unlinking_iface',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unlink_iface_error' => 'zombie/beating_to_death',
                                                                         '_on_unlink_iface_done' => 'starting/destroying_old_lxc'
                                                                       },
                                                      'enter' => '_unlink_iface'
                                                    },
                                                    'starting/destroying_old_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_destroy_lxc_done' => 'starting/allocating_os_overlayfs'
                                                                       },
                                                      'enter' => '_destroy_lxc'
                                                    },
                                                    'starting/allocating_os_overlayfs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_os_overlayfs_error' => 'stopping/releasing_untar_lock',
                                                                         '_on_allocate_os_overlayfs_done' => 'starting/allocating_os_rootfs'
                                                                       },
                                                      'enter' => '_allocate_os_overlayfs'
                                                    },
                                                    'starting/allocating_os_rootfs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_os_rootfs_error' => 'stopping/unmounting_filesystems',
                                                                         '_on_allocate_os_rootfs_done' => 'starting/allocating_home_fs'
                                                                       },
                                                      'enter' => '_allocate_os_rootfs'
                                                    },
                                                    'starting/allocating_home_fs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_allocate_home_fs_error' => 'stopping/unmounting_filesystems',
                                                                         '_on_allocate_home_fs_done' => 'starting/creating_lxc'
                                                                       },
                                                      'enter' => '_allocate_home_fs'
                                                    },
                                                    'starting/creating_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_create_lxc_done' => 'starting/removing_old_fw_rules',
                                                                         '_on_create_lxc_error' => 'stopping/destroying_lxc'
                                                                       },
                                                      'enter' => '_create_lxc'
                                                    },
                                                    'starting/removing_old_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'starting/configuring_lxc',
                                                                         '_on_remove_fw_rules_error' => 'zombie/beating_to_death'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'starting/configuring_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_configure_lxc_done' => 'starting/running_prestart_hook',
                                                                         '_on_configure_lxc_error' => 'stopping/destroying_lxc'
                                                                       },
                                                      'enter' => '_configure_lxc'
                                                    },
                                                    'starting/running_prestart_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'starting/setting_fw_rules',
                                                                         '_on_run_hook_error' => 'stopping/running_poststop_hook'
                                                                       },
                                                      'enter' => '_run_prestart_hook'
                                                    },
                                                    'starting/setting_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_fw_rules_error' => 'stopping/removing_fw_rules',
                                                                         '_on_set_fw_rules_done' => 'starting/launching'
                                                                       },
                                                      'enter' => '_set_fw_rules'
                                                    },
                                                    'starting/launching',
                                                    {
                                                      'transitions' => {
                                                                         '_on_start_lxc_done' => 'starting/waiting_for_vma',
                                                                         '_on_start_lxc_error' => 'stopping/killing_lxc'
                                                                       },
                                                      'enter' => '_start_lxc'
                                                    },
                                                    'starting/waiting_for_vma',
                                                    {
                                                      'transitions' => {
                                                                         '_on_alive' => 'running/saving_state',
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         '_on_stop_cmd' => 'stopping/deleting_cmd',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         'on_hkd_stop' => 'stopping/saving_state',
                                                                         '_on_goto_debug' => 'debugging/saving_state',
                                                                         '_on_dead' => 'stopping/stopping_lxc'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'running/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/saving_state',
                                                                         '_on_save_state_done' => 'running/updating_stats'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'running/updating_stats',
                                                    {
                                                      'ignore' => [
                                                                    '_on_incr_run_ok_result'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_incr_run_ok_error' => 'running/running_poststart_hook',
                                                                         '_on_incr_run_ok_done' => 'running/running_poststart_hook'
                                                                       },
                                                      'enter' => '_incr_run_ok'
                                                    },
                                                    'running/running_poststart_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'running/unsetting_heavy_mark',
                                                                         '_on_run_hook_error' => 'stopping/saving_state'
                                                                       },
                                                      'enter' => '_run_poststart_hook'
                                                    },
                                                    'running/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'running/monitoring'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'running/monitoring',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_stop' => 'stopping/deleting_cmd',
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         'on_hkd_stop' => 'stopping/saving_state',
                                                                         '_on_goto_debug' => 'debugging/saving_state',
                                                                         '_on_dead' => 'stopping/stopping_lxc'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'debugging/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/saving_state',
                                                                         '_on_save_state_done' => 'debugging/unsetting_heavy_mark'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'debugging/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'debugging/waiting_for_vma'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'debugging/waiting_for_vma',
                                                    {
                                                      'ignore' => [
                                                                    '_on_dead',
                                                                    '_on_goto_debug'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_cmd_stop' => 'stopping/deleting_cmd',
                                                                         '_on_alive' => 'running/saving_state',
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         'on_hkd_stop' => 'stopping/saving_state'
                                                                       },
                                                      'leave' => '_stop_vma_monitor',
                                                      'enter' => '_start_vma_monitor'
                                                    },
                                                    'stopping/deleting_cmd',
                                                    {
                                                      'transitions' => {
                                                                         '_on_delete_cmd_done' => 'stopping/saving_state'
                                                                       },
                                                      'enter' => '_delete_cmd'
                                                    },
                                                    'stopping/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'stopping/setting_heavy_mark',
                                                                         '_on_save_state_done' => 'stopping/setting_heavy_mark'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'stopping/setting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_set_heavy_mark_error' => 'stopping/delaying',
                                                                         '_on_set_heavy_mark_done' => 'stopping/powering_off'
                                                                       },
                                                      'enter' => '_set_heavy_mark'
                                                    },
                                                    'stopping/delaying',
                                                    {
                                                      'transitions' => {
                                                                         '_on_cmd_go_heavy' => 'stopping/setting_heavy_mark'
                                                                       }
                                                    },
                                                    'stopping/powering_off',
                                                    {
                                                      'transitions' => {
                                                                         '_on_rpc_poweroff_result' => 'stopping/waiting_for_lxc_to_exit',
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         '_on_rpc_poweroff_error' => 'stopping/stopping_lxc'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_poweroff'
                                                    },
                                                    'stopping/waiting_for_lxc_to_exit',
                                                    {
                                                      'transitions' => {
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         '_on_state_timeout' => 'stopping/stopping_lxc'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_set_state_timer'
                                                    },
                                                    'stopping/stopping_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_stop_lxc_done' => 'stopping/waiting_for_lxc_to_stop'
                                                                       },
                                                      'enter' => '_stop_lxc'
                                                    },
                                                    'stopping/waiting_for_lxc_to_stop',
                                                    {
                                                      'transitions' => {
                                                                         '_on_lxc_done' => 'stopping/killing_lxc',
                                                                         'on_hkd_kill' => 'stopping/killing_lxc',
                                                                         '_on_state_timeout' => 'stopping/killing_lxc'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_set_state_timer'
                                                    },
                                                    'stopping/killing_lxc',
                                                    {
                                                      'ignore' => [
                                                                    '_on_lxc_done',
                                                                    'on_hkd_kill'
                                                                  ],
                                                      'transitions' => {
                                                                         '_on_kill_lxc_done' => 'stopping/unlinking_iface',
                                                                         '_on_dirty' => 'dirty',
                                                                         '_on_kill_lxc_error' => 'zombie/beating_to_death'
                                                                       },
                                                      'enter' => '_kill_lxc'
                                                    },
                                                    'stopping/unlinking_iface',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unlink_iface_error' => 'zombie/beating_to_death',
                                                                         '_on_unlink_iface_done' => 'stopping/removing_fw_rules'
                                                                       },
                                                      'enter' => '_unlink_iface'
                                                    },
                                                    'stopping/removing_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'stopping/running_poststop_hook',
                                                                         '_on_remove_fw_rules_error' => 'zombie/beating_to_death'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'stopping/running_poststop_hook',
                                                    {
                                                      'transitions' => {
                                                                         '_on_run_hook_done' => 'stopping/destroying_lxc',
                                                                         '_on_run_hook_error' => 'stopping/destroying_lxc'
                                                                       },
                                                      'enter' => '_run_poststop_hook'
                                                    },
                                                    'stopping/destroying_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_destroy_lxc_done' => 'stopping/unmounting_filesystems'
                                                                       },
                                                      'enter' => '_destroy_lxc'
                                                    },
                                                    'stopping/unmounting_filesystems',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unmount_filesystems_error' => 'zombie/beating_to_death',
                                                                         '_on_unmount_filesystems_done' => 'stopping/releasing_untar_lock'
                                                                       },
                                                      'enter' => '_unmount_filesystems'
                                                    },
                                                    'stopping/releasing_untar_lock',
                                                    {
                                                      'transitions' => {
                                                                         '_on_release_untar_lock_done' => 'stopping/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_release_untar_lock'
                                                    },
                                                    'stopping/clearing_runtime_row',
                                                    {
                                                      'transitions' => {
                                                                         '_on_clear_runtime_row_error' => 'zombie/beating_to_death',
                                                                         '_on_clear_runtime_row_done' => 'stopped'
                                                                       },
                                                      'enter' => '_clear_runtime_row'
                                                    },
                                                    'stopped',
                                                    {
                                                      'enter' => '_call_on_stopped'
                                                    },
                                                    'zombie/beating_to_death',
                                                    {
                                                      'jump' => 'zombie/saving_state'
                                                    },
                                                    'zombie/saving_state',
                                                    {
                                                      'transitions' => {
                                                                         '_on_save_state_error' => 'zombie/calculating_attrs',
                                                                         '_on_save_state_done' => 'zombie/calculating_attrs'
                                                                       },
                                                      'enter' => '_save_state'
                                                    },
                                                    'zombie/calculating_attrs',
                                                    {
                                                      'transitions' => {
                                                                         '_on_calculate_attrs_done' => 'zombie/stopping_lxc'
                                                                       },
                                                      'enter' => '_calculate_attrs'
                                                    },
                                                    'zombie/stopping_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_stop_lxc_done' => 'zombie/waiting_for_lxc_to_stop'
                                                                       },
                                                      'enter' => '_stop_lxc'
                                                    },
                                                    'zombie/waiting_for_lxc_to_stop',
                                                    {
                                                      'transitions' => {
                                                                         '_on_wait_for_zombie_lxc_done' => 'zombie/killing_lxc'
                                                                       },
                                                      'enter' => '_wait_for_zombie_lxc'
                                                    },
                                                    'zombie/killing_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_kill_lxc_done' => 'zombie/unlinking_iface',
                                                                         '_on_dirty' => 'dirty',
                                                                         '_on_kill_lxc_error' => 'zombie/unsetting_heavy_mark'
                                                                       },
                                                      'enter' => '_kill_lxc'
                                                    },
                                                    'zombie/unlinking_iface',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unlink_iface_error' => 'zombie/unsetting_heavy_mark',
                                                                         '_on_unlink_iface_done' => 'zombie/removing_fw_rules'
                                                                       },
                                                      'enter' => '_unlink_iface'
                                                    },
                                                    'zombie/removing_fw_rules',
                                                    {
                                                      'transitions' => {
                                                                         '_on_remove_fw_rules_done' => 'zombie/destroying_lxc',
                                                                         '_on_remove_fw_rules_error' => 'zombie/unsetting_heavy_mark'
                                                                       },
                                                      'enter' => '_remove_fw_rules'
                                                    },
                                                    'zombie/destroying_lxc',
                                                    {
                                                      'transitions' => {
                                                                         '_on_destroy_lxc_error' => 'zombie/unmounting_filesystems',
                                                                         '_on_destroy_lxc_done' => 'zombie/unmounting_filesystems'
                                                                       },
                                                      'enter' => '_destroy_lxc'
                                                    },
                                                    'zombie/unmounting_filesystems',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unmount_filesystems_error' => 'zombie/unsetting_heavy_mark',
                                                                         '_on_unmount_filesystems_done' => 'zombie/releasing_untar_lock'
                                                                       },
                                                      'enter' => '_unmount_filesystems'
                                                    },
                                                    'zombie/releasing_untar_lock',
                                                    {
                                                      'transitions' => {
                                                                         '_on_release_untar_lock_done' => 'zombie/clearing_runtime_row'
                                                                       },
                                                      'enter' => '_release_untar_lock'
                                                    },
                                                    'zombie/clearing_runtime_row',
                                                    {
                                                      'transitions' => {
                                                                         '_on_clear_runtime_row_error' => 'zombie/unsetting_heavy_mark',
                                                                         '_on_clear_runtime_row_done' => 'stopped'
                                                                       },
                                                      'enter' => '_clear_runtime_row'
                                                    },
                                                    'zombie/unsetting_heavy_mark',
                                                    {
                                                      'transitions' => {
                                                                         '_on_unset_heavy_mark_done' => 'zombie'
                                                                       },
                                                      'enter' => '_unset_heavy_mark'
                                                    },
                                                    'zombie',
                                                    {
                                                      'ignore' => [
                                                                    'on_hkd_stop'
                                                                  ],
                                                      'transitions' => {
                                                                         'on_hkd_kill' => 'stopped',
                                                                         '_on_state_timeout' => 'zombie/killing_lxc'
                                                                       },
                                                      'leave' => '_abort_all',
                                                      'enter' => '_set_state_timer'
                                                    },
                                                    'dirty',
                                                    {
                                                      'transitions' => {
                                                                         'on_hkd_kill' => 'stopped',
                                                                         'on_hkd_stop' => 'stopped'
                                                                       }
                                                    },
                                                    '__any__',
                                                    {
                                                      'delay_once' => [
                                                                        '_on_cmd_stop',
                                                                        '_on_lxc_done',
                                                                        'on_hkd_stop',
                                                                        'on_hkd_kill'
                                                                      ]
                                                    }
                                                  ]
                  );
