# Author(s):
#   - Spyridon Poursalidis <s.poursalidis@gmail.com>
#
set ip_design       AXI_QoS_Interconnect
set ip_top          axi4_qos_interconnect
set ip_proj_dir     ip_project
set ip_version      1.00
set LIBRARY_NAME    spoursalidis
set VENDOR_NAME     spoursalidis 
set ENGINEER_NAME   spoursalidiss
set fpga_device     <add your fpga device>

create_project -name ${ip_design} -force -dir "./${ip_proj_dir}" -part ${fpga_device} -ip
set_property source_mgmt_mode ALL [current_project]
set_property top ${ip_top} [current_fileset]

# Add all VHDL Modules in hdl-folder
read_vhdl -vhdl2008 -library work [ glob ./hdl/*.vhd]

ipx::package_project

set_property widget {textEdit} [ipgui::get_guiparamspec -name "NUM_SLAVES" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters NUM_SLAVES -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 1 [ipx::get_user_parameters NUM_SLAVES -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 8 [ipx::get_user_parameters NUM_SLAVES -of_objects [ipx::current_core]]

set_property enablement_dependency {$NUM_SLAVES > 1} [ipx::get_bus_interfaces s_axi_1 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 2} [ipx::get_bus_interfaces s_axi_2 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 3} [ipx::get_bus_interfaces s_axi_3 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 4} [ipx::get_bus_interfaces s_axi_4 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 5} [ipx::get_bus_interfaces s_axi_5 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 6} [ipx::get_bus_interfaces s_axi_6 -of_objects [ipx::current_core]]
set_property enablement_dependency {$NUM_SLAVES > 7} [ipx::get_bus_interfaces s_axi_7 -of_objects [ipx::current_core]]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property name ${ip_design} [ipx::current_core]
set_property library $LIBRARY_NAME [ipx::current_core]
set_property vendor_display_name $ENGINEER_NAME [ipx::current_core]
set_property vendor $VENDOR_NAME [ipx::current_core]
set_property version ${ip_version} [ipx::current_core]
set_property display_name ${ip_design} [ipx::current_core]
set_property description ${ip_design} [ipx::current_core]

ipx::infer_user_parameters [ipx::current_core]

ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project
