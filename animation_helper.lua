local animation_helper = {}

local categories = {
    "additive",
    "all",
    -- "bear",
    "bow",
    -- "elephant",
    -- "facial",
    "fist",
    -- "horse",
    -- "lion",
    -- "lmg_files",
    "loginstage",
    "machinima",
    -- "machinima_facial",
    "music",
    "onehand",
    -- "pangolin",
    -- "propoise",
    -- "robot",
    -- "seabug",
    -- "special",
    "staff",
    "twohand",
    "twoswords",
    -- "wildboar",
    -- "wyvern",
}
animation_helper.categories = categories

local animationData = {
    ["additive"] = {
        "additive_all_co_combat_miss",
        "additive_all_co_combat_parry",
        "additive_all_re_combat_confuse",
        "additive_all_re_combat_hit",
        "additive_all_re_combat_hit_b" ,
        "additive_all_re_combat_hit_f",
        "additive_all_re_combat_hit_l",
    },
    ["all"] = {
        "all_co_sk_dashattack",
        "all_co_sk_flyingkick",
        "all_co_sk_spell_launch_energyshot",
        "all_co_sk_spell_launch_dragonwind",
        "all_co_sk_spell_launch_devilsword",
        "all_co_sk_spell_launch_dead",
        "all_co_sk_spell_channel_medusa",
        "all_co_sk_swim_whirlwind_cast",
        "all_co_sk_trample",
        "all_co_sk_spell_launch_fireball",
        "all_co_sk_swim_spell_cast_fireball",
        "all_co_sk_spell_launch_flash",
        "all_co_sk_spell_launch_ground",
        "all_co_sk_spell_launch_fireball2",
        "all_co_sk_spell_launch_fireball3",
        "all_co_sk_spell_launch_spear",
        "all_co_sk_spell_launch_shield",
        "all_co_sk_spell_launch_summon"
    },
    ["bow"] = {
        "bow_co_attack",
        "bow_co_sk_cast",
        "bow_co_sk_cast_2",
        "bow_co_sk_cast_3",
        "bow_co_sk_cast_4",
        "bow_co_sk_cast_5",
        "bow_co_sk_cast_start",
        "bow_co_sk_high_cast",
        "bow_co_sk_high_launch",
        "bow_co_sk_launch",
        "bow_co_sk_launch_skill_launch",
        "bow_co_sk_launch_beastrush",
        "bow_co_sk_launch_snakeeye",
        "bow_co_sk_swim_cast",
        "bow_co_sk_swim_cast_2",
        "bow_co_sk_swim_cast_3",
        "bow_co_sk_swim_cast_4",
        "bow_co_sk_swim_cast_5",
        "bow_co_sk_swim_launch_beastrush",
    },
    ["fist"] = {
        "fist_ba_relaxed_rand_idle",
        "fist_ac_anchor_steer_l",
        "fist_ac_anchor_steer_r",
        "fist_ac_ballista_fire",
        "fist_ac_ballista_release",
        "fist_ac_bathtub_loop",
        "fist_ac_bathtub_mermaid_loop",
        "fist_ac_beggar_01",
        "fist_ac_board_b",
        "fist_ac_boarding",
        "fist_ac_cannon_standby",
        "fist_ac_eat",
        "fist_ac_eatsuop",
        "fist_ac_gliding_idle",
        "fist_ac_gliding_back",
        "fist_ac_gliding_front",
        "fist_ac_gliding_broom_idle",
        "fist_ac_gliding_panda_idle",
        "fist_ac_gliding_spin",
        "fist_ac_gliding_tumbling_back",
        "fist_ac_gliding_tumbling_front",
        "fist_ac_gliding_wing_idle",
        "fist_ac_gliding_wing_spell_launch",
        "fist_ac_gliding_wing_telpo_l",
        "fist_ac_gliding_wing_leapattack_launch",
        "fist_ac_gliding_wing_grounding",
        "fist_ac_gliding_wing_grounding_end",
        "fist_ac_punishment_critical",
        "fist_ac_slaughter",
        "fist_em_umbrella_loop",
        "fist_em_fan_loop",

    },
    ["loginstage"] = {
        "loginstage_class_healer",
        "loginstage_class_healer_end",
        "loginstage_class_healer_idle",
        "loginstage_class_melee",
        "loginstage_class_melee_end",
        "loginstage_class_melee_idle",
        "loginstage_class_ranger",
        "loginstage_class_ranger_end",
        "loginstage_class_ranger_idle",
        "loginstage_class_sorcerer",
        "loginstage_class_sorcerer_end",
        "loginstage_class_sorcerer_idle",
        "loginstage_tribe_select",
    },
    ["machinima"] = {
        "all_10_c12_elpis",
        "dw_02_c06_ch1",
        "el_02_s23_enoir",
        "all_02_memory_sc02_c01_elpis",
        "id_300_10_c02_cap01",
        "wb_05_c07_comm",
        "all_09_c01_elpis",
        "wb_06_s02_c02_king",
        "el_02_s16_pc",
        "all_02_memory_sc01_c04_pc",
        "all_01_recruit_sc01_c01_npc",
        "el_01_dagger",
        "el_02_s01_delto",
        "el_02_s28_pc",
        "dw_05_c04_ch2",
    },
    ["music"] = {
        "music_ba_combat_idle",
        "music_co_sk_contrabass_cast",
        "music_co_sk_contrabass_idle",
        "music_co_sk_drum",
        "music_co_sk_drum_cast",
        "music_co_sk_lute_cast",
        "music_co_sk_lute_cast_immortal",
        "music_co_sk_oregol_cast",
        "music_co_sk_pipe_cast",
        "music_co_sk_violin_cast",
        "music_co_sk_string_cast",
        "music_co_sk_sit_down_drum_cast",
        "music_co_sk_sit_down_cello_cast",
        "music_co_sk_sit_down_piano_cast",
        "music_co_sk_sitground_lute_cast",
        "music_co_sk_sitground_pipe_cast",
    },
    ["onehand"] = {
        "onehand_ac_holster_side_l",
        "onehand_ba_combat_idle",
        "onehand_ba_idle_swim",
        "onehand_ba_stealth_idle",
        "onehand_co_attack_l_blunt",
        "onehand_co_attack_l_blunt_2",
        "onehand_co_attack_l_pierce",
        "onehand_co_attack_l_pierce_2",
        "onehand_co_attack_l_slash",
        "onehand_co_attack_l_slash_2",
        "onehand_co_attack_r_blunt",
        "onehand_co_attack_r_blunt_2",
        "onehand_co_attack_r_pierce",
        "onehand_co_attack_r_pierce_2",
        "onehand_co_attack_r_slash",
        "onehand_co_attack_r_slash_2",
        "onehand_co_sk_cast",
        "onehand_co_sk_fastattack_1",
        "onehand_co_sk_fastattack_2",
        "onehand_co_sk_fastattack_3",
        "onehand_co_sk_fastattack_4",
        "onehand_co_sk_impregnable",
        "onehand_co_sk_shielddefense",
        "onehand_co_sk_shieldpush",
        "onehand_co_sk_shieldwield",
        "onehand_co_sk_throwdagger",
        "onehand_co_sk_shieldthrow_cast",
        "onehand_co_sk_shieldthrow_launch",
    },
    ["staff"] = {
        "staff_ac_holster_staff_l",
        "staff_co_attack",
        "staff_co_attack_2",
    },
    ["twohand"] = {
        "twohand_ac_holster_back_r",
        "twohand_ac_omizutori",
        "twohand_ba_combat_idle",
        "twohand_ba_idle_swim",
        "twohand_co_attack",
        "twohand_co_attack_mub",
        "twohand_co_sk_fastattack_1",
        "twohand_co_sk_fastattack_2",
        "twohand_co_sk_fastattack_3",
        "twohand_co_sk_fastattack_4",
        "twohand_co_sk_streakattack_1",
        "twohand_co_sk_streakattack_2",
        "twohand_co_sk_streakattack_3",
        "twohand_co_sk_weapon_blunt",
        "twohand_co_sk_weapon_pierce",
        "twohand_co_sk_weapon_slash",
        "twohand_co_swim_attack_ub",
    },
    ["twoswords"] = {
        "twoswords_co_sk_fastattack_1",
        "twoswords_co_sk_fastattack_2",
        "twoswords_co_sk_fastattack_3",
        "twoswords_co_sk_fastattack_4",
        "twoswords_co_sk_leapattack",
        "twoswords_co_sk_streakattack_1",
        "twoswords_co_sk_streakattack_2",
        "twoswords_co_sk_streakattack_3",
        "twoswords_co_sk_swim_fastattack_1_ub",
        "twoswords_co_sk_swim_fastattack_2_ub",
        "twoswords_co_sk_swim_fastattack_3_ub",
        "twoswords_co_sk_swim_fastattack_4_ub",
        "twoswords_co_sk_swim_leapattack_ub",
        "twoswords_co_sk_swim_streakattack_1_ub",
        "twoswords_co_sk_swim_streakattack_2_ub",
        "twoswords_co_sk_swim_streakattack_3_ub",
        "twoswords_co_sk_weapon_blunt",
        "twoswords_co_sk_weapon_pierce",
        "twoswords_co_sk_weapon_slash",
        "twoswords_co_sk_weapon_slash_3",
    }
}
animation_helper.animationData = animationData

return animation_helper