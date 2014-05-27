#!/usr/bin/perl

use strict;
use warnings;

use gv;
use Class::StateMachine::Declarative::Graphviz;

my $decl =
[ new      => { transitions => { _on_cmd_start        => 'starting',
                                 _on_cmd_catch_zombie => 'zombie'          } },

  starting => { advance_when => '_on_done',
                substates => [ saving_state    => { enter       => '_save_state',
                                                    transitions => { _on_save_state_error         => 'stopped' } },

                               db              => { transitions => { on_error => 'stopping/db' },
                                                    substates   => [ loading_row        => { enter => '_load_row' },
                                                                     updating_stats     => { enter => '_incr_run_attempts' },
                                                                     searching_di       => { enter => '_search_di' },
                                                                     saving_runtime_row => { enter => '_save_runtime_row' },
                                                                     deleting_cmd       => { enter => '_delete_cmd',
                                                                                             transitions => { _on_error => 'calculating_attrs' } },
                                                                     calculating_attrs  => { enter => '_calculate_attrs' } ] },

                               clean_old       => { transitions => { on_error => 'zombie' },
                                                    substates   => [ killing_lxc       => { enter => '_kill_lxc' },
                                                                     unlinking_iface   => { enter => '_unlink_iface' },
                                                                     destroying_lxc    => { enter => '_destroy_lxc' },
                                                                     removing_fw_rules => { enter => '_remove_fw_rules' } ] },

                               heavy           => { substates   => [ delaying     => { secondary => 1 }, # transitions => { _on_cmd_go_heavy             => 'setting_heavy_mark'       } },
                                                                     setting_mark => { enter => '_set_heavy_mark',
                                                                                       transitions => {_on_error => 'delaying' } } ] },

                               setup           => { transitions => { on_error => 'stopping/cleanup' },
                                                    substates   => [ delaying => { secondary => 1,
                                                                                   enter => '_delay_untar_os_image',
                                                                                   leave => '_abort_call_after',
                                                                                   transitions => { _on_done => 'heavy/setting_mark' } },
                                                                     untaring_os_image       => { enter => '_untar_os_image',
                                                                                                  transitions => { _on_eagain => 'delaying' } },
                                                                     placing_os_image        => { enter => '_place_os_image' },
                                                                     detecting_os_image_type => { enter => '_detect_os_image_type' },
                                                                     allocating_os_overlayfs => { enter => '_allocate_os_overlayfs' },
                                                                     allocating_os_rootfs    => { enter => '_allocate_os_rootfs' },
                                                                     allocating_home_fs      => { enter => '_allocate_home_fs' },
                                                                     creating_lxc            => { enter => '_create_lxc' },
                                                                     configuring_lxc         => { enter => '_configure_lxc' },
                                                                     running_prestart_hook   => { enter => '_run_prestart_hook' },
                                                                     setting_fw_rules        => { enter => '_set_fw_rules' },
                                                                     launching               => { enter => '_start_lxc' } ] },

                               waiting_for_vma => { enter       => '_start_vma_monitor',
                                                    leave       => '_stop_vma_monitor',
                                                    transitions => { _on_alive      => 'running',
                                                                     _on_goto_debug => 'debugging',
                                                                     _on_stop_cmd   => 'stopping/cmd',
                                                                     on_hkd_stop    => 'stopping/stop',
                                                                     _on_dead       => 'stopping/stop',
                                                                     _on_lxc_done   => 'stopping/cleanup' } } ] },

  running  => { advance_when => '_on_done',
                delay => [qw(_on_lxc_done)],
                transitions => { _on_error => 'stopping/stop' },
                substates => [ saving_state           => { enter       => '_save_state' },
                               updating_stats         => { enter       => '_incr_run_ok',
                                                           transitions =>  { _on_error => 'running_poststart_hook'  } },
                               running_poststart_hook => { enter       => '_run_poststart_hook' },
                               unsetting_heavy_mark   => { enter       => '_unset_heavy_mark' },
                               monitoring             => { enter       => '_start_vma_monitor',
                                                           leave       => '_stop_vma_monitor',
                                                           transitions => { _on_cmd_stop                 => 'stopping/cmd',
                                                                            on_hkd_stop                  => 'stopping/stop',
                                                                            _on_dead                     => 'stopping/stop',
                                                                            _on_goto_debug               => 'debugging',
                                                                            _on_lxc_done                 => 'stopping/cleanup'            } } ] },

  debugging => { advance_when => '_on_done',
                 delay => [qw(_on_lxc_done)],
                 transitions => { _on_error => 'stopping/stop' },
                 substates => [ saving_state          => { enter       => '_save_state' },
                                unsetting_heavy_mark  => { enter       => '_unset_heavy_mark' },
                                waiting_for_vma       => { enter       => '_start_vma_monitor',
                                                           leave       => '_stop_vma_monitor',
                                                           transitions => { _on_alive                    => 'running',
                                                                            _on_cmd_stop                 => 'stopping/cmd',
                                                                            on_hkd_stop                  => 'stopping/stop',
                                                                            _on_lxc_done                 => 'stopping/cleanup' },
                                                           ignore      => [qw(_on_dead _on_goto_debug)] } ] },

  stopping => { advance_when => '_on_done',
                delay => [qw(_on_lxc_done)],
                substates => [ cmd                    => { advance_when => '_on_error',
                                                           substates => [ saving_state => { enter => '_sabe_state' },
                                                                          deleting_cmd => { enter => '_delete_cmd' } ] },

                               shutdown               => { substates => [ saving_state => { enter => '_save_state' },
                                                                          setting_heavy_mark => { enter => '_set_heavy_mark',
                                                                                                  transitions => { _on_error => 'delaying',
                                                                                                                   _on_done => 'shuttingdown' } },
                                                                          delaying     => { transitions => { _on_cmd_go_heavy => 'shuttingdown' } },
                                                                          shuttingdown => { enter => '_shutdown',
                                                                                            leave       => '_abort_all',
                                                                                            transitions => { _on_rpc_poweroff_error       => 'stop',
                                                                                                             _on_lxc_done                 => 'cleanup',
                                                                                                             _on_rpc_poweroff_result      => 'waiting_for_lxc'} },

                                                                          waiting_for_lxc => { enter       => '_set_state_timer',
                                                                                               leave       => '_abort_all',
                                                                                               transitions => { _on_lxc_done                 => 'cleanup',
                                                                                                                _on_state_timeout            => 'stop' } } ] },

                               stop                   => { substates => [ saving_state => { enter => '_save_state' },
                                                                          running_stop => { enter => '_stop_lxc' },
                                                                          waiting      => { enter => '_set_state_timer',
                                                                                            leave => '_abort_all',
                                                                                            transitions => { _on_lxc_done => 'cleanup',
                                                                                                             _on_timeout => 'cleanup' } } ] },
                               cleanup                => { transitions => { _on_error => 'zombie' },
                                                           substates => [ saving_state           => { enter => '_save_state' },
                                                                          killing_lxc            => { enter => '_kill_lxc' },
                                                                          unlinking_iface        => { enter => '_unlink_iface' },
                                                                          removing_fw_rules      => { enter => '_remove_fw_rules' },
                                                                          running_poststop_hook  => { enter => '_run_poststop_hook',
                                                                                                     transitions => { _on_error => 'destroying_lxc' } },
                                                                          destroying_lxc         => { enter => '_destroy_lxc' },
                                                                          unmounting_filesystems => { enter => '_unmount_filesystems' },
                                                                          releasing_untar_lock   => { enter => '_release_untar_lock' } ] },
                               db                     => { enter => '_clear_runtime_row',
                                                           transitions => { _on_error => 'zombie' } } ] },

  stopped => { enter       => '_call_on_stopped' },

  zombie  => { advance_when => '_on_done',
               transitions => { _on_dirty => 'dirty',
                                _on_error => 'unsetting_heavy_mark' },
               substates => [ saving_state             => { enter => '_save_state',
                                                            transitions => { _on_error => 'calculating_attrs' } },
                              calculating_attrs        => { enter => '_calculate_attrs' },
                              stopping_lxc             => { enter => '_stop_lxc',
                                                            transitions => { _on_stop_lxc_done => 'waiting_for_lxc_to_stop' } },
                              waiting_for_lxc_to_stop  => { enter => '_wait_for_zombie_lxc' },
                              killing_lxc              => { enter => '_kill_lxc' },
                              unlinking_iface          => { enter => '_unlink_iface' },
                              removing_fw_rules        => { enter => '_remove_fw_rules' },
                              destroying_lxc           => { enter => '_destroy_lxc',
                                                            transitions => { _on_error => 'unmounting_filesystems'  } },
                              unmounting_filesystems   => { enter => '_unmount_filesystems' },
                              releasing_untar_lock     => { enter => '_release_untar_lock' },
                              clearing_runtime_row     => { enter => '_clear_runtime_row',
                                                            transitions => { _on_done    => 'stopped' } },
                              unsetting_heavy_mark     => { enter => '_unset_heavy_mark' },
                              idle                     => { enter => '_set_state_timer',
                                                            leave => '_abort_all',
                                                            transitions => { _on_timeout => 'stopping_lxc',
                                                                             on_hkd_kill => 'stopped' } } ] },

  dirty  => { transitions => { on_hkd_kill => 'stopped' } },

  __any__ => { transitions => { _on_dirty => 'dirty' } }

];

my $class = 'QVD::LXC';
my $graph = gv::digraph($class);
my $drawer = Class::StateMachine::Declarative::Graphviz->new;
$drawer->draw_state_machine($graph, $class, $decl);
$graph->gv::write("$class.dot");

