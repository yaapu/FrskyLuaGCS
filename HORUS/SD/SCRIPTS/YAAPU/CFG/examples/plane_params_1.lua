--[[
const AP_Param::GroupInfo SoaringController::var_info[] = {
    // @Param: ENABLE
    // @DisplayName: Is the soaring mode enabled or not
    // @Description: Toggles the soaring mode on and off
    // @Values: 0:Disable,1:Enable
    // @User: Advanced
    AP_GROUPINFO_FLAGS("ENABLE", 1, SoaringController, soar_active, 0, AP_PARAM_FLAG_ENABLE),

    // @Param: VSPEED
    // @DisplayName: Vertical v-speed
    // @Description: Rate of climb to trigger themalling speed
    // @Units: m/s
    // @Range: 0 10
    // @User: Advanced
    AP_GROUPINFO("VSPEED", 2, SoaringController, thermal_vspeed, 0.7f),

    // @Param: Q1
    // @DisplayName: Process noise
    // @Description: Standard deviation of noise in process for strength
    // @Units:
    // @Range: 0 10
    // @User: Advanced
    AP_GROUPINFO("Q1", 3, SoaringController, thermal_q1, 0.001f),

    // @Param: Q2
    // @DisplayName: Process noise
    // @Description: Standard deviation of noise in process for position and radius
    // @Units:
    // @Range: 0 10
    // @User: Advanced
    AP_GROUPINFO("Q2", 4, SoaringController, thermal_q2, 0.03f),

    // @Param: R
    // @DisplayName: Measurement noise
    // @Description: Standard deviation of noise in measurement
    // @Units:
    // @Range: 0 10
    // @User: Advanced

    AP_GROUPINFO("R", 5, SoaringController, thermal_r, 0.45f),

    // @Param: DIST_AHEAD
    // @DisplayName: Distance to thermal center
    // @Description: Initial guess of the distance to the thermal center
    // @Units: m
    // @Range: 0 100
    // @User: Advanced
    AP_GROUPINFO("DIST_AHEAD", 6, SoaringController, thermal_distance_ahead, 5.0f),

    // @Param: MIN_THML_S
    // @DisplayName: Minimum thermalling time
    // @Description: Minimum number of seconds to spend thermalling
    // @Units: s
    // @Range: 0 32768
    // @User: Advanced
    AP_GROUPINFO("MIN_THML_S", 7, SoaringController, min_thermal_s, 20),

    // @Param: MIN_CRSE_S
    // @DisplayName: Minimum cruising time
    // @Description: Minimum number of seconds to spend cruising
    // @Units: s
    // @Range: 0 32768
    // @User: Advanced
    AP_GROUPINFO("MIN_CRSE_S", 8, SoaringController, min_cruise_s, 30),

    // @Param: POLAR_CD0
    // @DisplayName: Zero lift drag coef.
    // @Description: Zero lift drag coefficient
    // @Units:
    // @Range: 0 0.5
    // @User: Advanced
    AP_GROUPINFO("POLAR_CD0", 9, SoaringController, polar_CD0, 0.027),

    // @Param: POLAR_B
    // @DisplayName: Induced drag coeffient
    // @Description: Induced drag coeffient
    // @Units:
    // @Range: 0 0.5
    // @User: Advanced
    AP_GROUPINFO("POLAR_B", 10, SoaringController, polar_B, 0.031),

    // @Param: POLAR_K
    // @DisplayName: Cl factor
    // @Description: Cl factor 2*m*g/(rho*S)
    // @Units: m.m/s/s
    // @Range: 0 0.5
    // @User: Advanced
    AP_GROUPINFO("POLAR_K", 11, SoaringController, polar_K, 25.6),

    // @Param: ALT_MAX
    // @DisplayName: Maximum soaring altitude, relative to the home location
    // @Description: Don't thermal any higher than this.
    // @Units: m
    // @Range: 0 1000.0
    // @User: Advanced
    AP_GROUPINFO("ALT_MAX", 12, SoaringController, alt_max, 350.0),

    // @Param: ALT_MIN
    // @DisplayName: Minimum soaring altitude, relative to the home location
    // @Description: Don't get any lower than this.
    // @Units: m
    // @Range: 0 1000.0
    // @User: Advanced
    AP_GROUPINFO("ALT_MIN", 13, SoaringController, alt_min, 50.0),

    // @Param: ALT_CUTOFF
    // @DisplayName: Maximum power altitude, relative to the home location
    // @Description: Cut off throttle at this alt.
    // @Units: m
    // @Range: 0 1000.0
    // @User: Advanced
    AP_GROUPINFO("ALT_CUTOFF", 14, SoaringController, alt_cutoff, 250.0),
    
    // @Param: ENABLE_CH
    // @DisplayName: (Optional) RC channel that toggles the soaring controller on and off
    // @Description: Toggles the soaring controller on and off. This parameter has any effect only if SOAR_ENABLE is set to 1 and this parameter is set to a valid non-zero channel number. When set, soaring will be activated when RC input to the specified channel is greater than or equal to 1700.
    // @Range: 0 16
    // @User: Advanced
    AP_GROUPINFO("ENABLE_CH", 15, SoaringController, soar_active_ch, 0),

--]]
local description = "Soaring Parameters"
--[[
VALUE
{ 
  1 name,
  2 min,  
  3 max, 
  4 increment
  5 unit of measure, 
}

COMBO
{
  1 name, 
  2 label list, 
  3 value list, 
}
--]]
local parameters = {
    --// @Range: 0 10
    --AP_GROUPINFO("VSPEED", 2, SoaringController, thermal_vspeed, 0.7f),
    {"SOAR_VSPEED"  , 0, 10, 0.05, "m/s"},
    
    --// @Range: 0 10
    --AP_GROUPINFO("Q1", 3, SoaringController, thermal_q1, 0.001f),
    {"SOAR_Q1"  , 0, 10, 0.0005},

    --// @Range: 0 10
    --AP_GROUPINFO("Q2", 4, SoaringController, thermal_q2, 0.03f),
    {"SOAR_Q2"  , 0, 10, 0.005},

    --// @Range: 0 10
    --AP_GROUPINFO("R", 5, SoaringController, thermal_r, 0.45f),
    {"SOAR_R"  , 0, 10, 0.01},

    --// @Range: 0 100
    --AP_GROUPINFO("DIST_AHEAD", 6, SoaringController, thermal_distance_ahead, 5.0f),
    {"SOAR_DIST_AHEAD"  , 0, 100, 1},

    --// @Range: 0 32768
    --AP_GROUPINFO("MIN_THML_S", 7, SoaringController, min_thermal_s, 20),
    {"SOAR_MIN_THML_S"  , 0, 32768, 1},

    --// @Range: 0 32768
    --AP_GROUPINFO("MIN_CRSE_S", 8, SoaringController, min_cruise_s, 30),
    {"SOAR_MIN_CRSE_S"  , 0, 32768, 1},

    --// @Range: 0 0.5
    --AP_GROUPINFO("POLAR_CD0", 9, SoaringController, polar_CD0, 0.027),
    {"SOAR_POLAR_CD0"  , 0, 0.5, 0.001},

    --// @Range: 0 0.5
    --AP_GROUPINFO("POLAR_B", 10, SoaringController, polar_B, 0.031),
    {"SOAR_POLAR_B"  , 0, 0.5, 0.001},

    --// @Range: 0 0.5
    --AP_GROUPINFO("POLAR_K", 11, SoaringController, polar_K, 25.6),
    {"SOAR_POLAR_K"  , 0, 100, 0.1},

    --// @Range: 0 1000.0
    --AP_GROUPINFO("ALT_MAX", 12, SoaringController, alt_max, 350.0),
    {"SOAR_ALT_MAX"  , 0, 1000, 1},

    --// @Range: 0 1000.0
    --AP_GROUPINFO("ALT_MIN", 13, SoaringController, alt_min, 50.0),
    {"SOAR_ALT_MIN"  , 0, 1000, 1},

    --// @Range: 0 1000.0
    --AP_GROUPINFO("ALT_CUTOFF", 14, SoaringController, alt_cutoff, 250.0),
    {"SOAR_ALT_CUTOFF"  , 0, 1000, 1},
    
    --// @Range: 0 16
    --AP_GROUPINFO("ENABLE_CH", 15, SoaringController, soar_active_ch, 0),
    {"SOAR_ENABLE_CH"  , 0, 16, 1},
}

return {list=parameters,description=description}
