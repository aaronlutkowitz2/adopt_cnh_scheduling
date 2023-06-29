view: input_loop_table_final {
  sql_table_name: `cloudadopt.cnh_scheduling.input_loop_table_final10`
    ;;

###########################
### Original Dimensions ###
###########################

## PK

  dimension: pk_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.pk_id ;;
  }

## Date

  dimension_group: date {
    label: "Schedule"
    type: time
    timeframes: [
      raw,
      week,
      week_of_year,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: request_status {
    group_label: "Status"
    type: string
    sql: ${TABLE}.request_status ;;
  }

  dimension: is_stationed_at_hospital {
    group_label: "Status"
    type: yesno
    sql: ${TABLE}.is_stationed_at_hospital ;;
  }

## Doctor

  dimension: doctor_id {
    group_label: "Doctor"
    type: number
    sql: ${TABLE}.doctor_id ;;
  }

  dimension: first_name {
    group_label: "Doctor"
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    group_label: "Doctor"
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: full_name {
    group_label: "Doctor"
    type: string
    sql: ${last_name} || ' ' || ${first_name} ;;
  }

## Hospital

  dimension: hospital_id {
    group_label: "Hospital"
    type: number
    sql: ${TABLE}.hospital_id ;;
  }

  dimension: hospital_code {
    group_label: "Hospital"
    type: string
    sql: ${TABLE}.hospital_code ;;
    html:
      <a href="#drillmenu" target="_self">
        {% if value == 'HCH' %}
          <p style="color: white; background-color: darkblue; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% elsif value == 'MWH' %}
          <p style="color: white; background-color: green; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% elsif value == 'HSC' %}
          <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% elsif value == 'SBHC' %}
          <p style="color: white; background-color: blue; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% elsif value == 'SZ' %}
          <p style="color: white; background-color: purple; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% elsif value == 'VHC' %}
          <p style="color: white; background-color: teal; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% else %}
          <p style="color: black; background-color: white; font-size:100%; text-align:center">{{ rendered_value }}</p>
        {% endif %}
      </a>
    ;;
  }

  dimension: hospital_name {
    group_label: "Hospital"
    type: string
    sql: ${TABLE}.hospital_name ;;
  }

  dimension: is_main_campus {
    group_label: "Hospital"
    type: yesno
    sql: ${TABLE}.is_main_campus ;;
  }

## Loops

  dimension: loop_id {
    group_label: "Loop"
    type: number
    sql: ${TABLE}.loop_id ;;
  }

  dimension: loop_id_5 {
    group_label: "Loop Id 05"
    type: number
    sql: round(${loop_id} / 5,0) * 5 ;;
  }

  dimension: loop_id_10 {
    group_label: "Loop"
    type: number
    sql: round(${loop_id} / 10,0) * 10 ;;
  }

  dimension: loop_id_25 {
    group_label: "Loop"
    type: number
    sql: round(${loop_id} / 25,0) * 25 ;;
  }

  dimension: loop_id_50 {
    group_label: "Loop"
    type: number
    sql: round(${loop_id} / 50,0) * 50 ;;
  }

  dimension: loop_score {
    group_label: "Loop"
    type: number
    sql: (${TABLE}.loop_score) / 1000 ;;
  }

###########################
### Derived Dimensions ###
###########################

###########################
### Measures ###
###########################

  set: drill {
    fields: [
        hospital_code
      , full_name
      , date_week
      , loop_id
      , loop_score
      , request_status
    ]
  }

  measure: max_hospital_code {
    label: "Hospital Code"
    type: string
    sql: max(${hospital_code}) ;;
    html:
      <a href="#drillmenu" target="_self">
      {% if value == 'HCH' %}
      <p style="color: white; background-color: darkblue; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value == 'MWH' %}
      <p style="color: white; background-color: green; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value == 'HSC' %}
      <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value == 'SBHC' %}
      <p style="color: white; background-color: blue; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value == 'SZ' %}
      <p style="color: white; background-color: purple; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value == 'VHC' %}
      <p style="color: white; background-color: teal; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% else %}
      <p style="color: black; background-color: white; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% endif %}
      </a>
    ;;
    drill_fields: [drill*]
  }

  measure: count {
    type: count
    drill_fields: [drill*]
  }

  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
    drill_fields: [drill*]
  }

  measure: sum_loop_score {
    group_label: "Loop"
    type: sum
    sql: ${loop_score} ;;
    value_format_name: decimal_1
    drill_fields: [drill*]
  }

  measure: average_loop_score {
    group_label: "Loop"
    type: average
    sql: ${loop_score} ;;
    value_format_name: decimal_1
    drill_fields: [drill*]
  }

  measure: running_total_loop_score {
    group_label: "Loop"
    type: running_total
    sql: ${loop_score} ;;
    value_format_name: decimal_0
    drill_fields: [drill*]
  }

### Hospital Expected Doctors (Weekly)

  measure: hospital_doctor_needs_weekly_actual {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Weekly)"
    label: "1 - Hospital's Doctor Needs (Weekly) - Actual"
    type: number
    sql: ${count} ;;
  }

  measure: hospital_doctor_needs_weekly_expected {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Weekly)"
    label: "2 - Hospital's Doctor Needs (Weekly) - Expected"
    type: average
    sql: ${hospital_dimension.weekly_doctor_target} ;;
    value_format_name: decimal_0
  }

  measure: hospital_doctor_needs_weekly_actual_vs_expected_abs_diff {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Weekly)"
    label: "3 - Hospital's Doctor Needs (Weekly) - Abs Difference"
    type: number
    sql: ${hospital_doctor_needs_weekly_actual} - ${hospital_doctor_needs_weekly_expected} ;;
    value_format_name: decimal_0
    html:
    <a href="#drillmenu" target="_self">
    {% if value == 0 %}
    <p style="color: white; background-color: green; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_weekly_actual._value }} Act vs {{ hospital_doctor_needs_weekly_expected._rendered_value}} Exp)</p>
    {% elsif value > 4 or value < -4 %}
    <p style="color: white; background-color: red; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_weekly_actual._value }} Act vs {{ hospital_doctor_needs_weekly_expected._rendered_value}} Exp)</p>
    {% elsif value > 2 or value < -2 %}
    <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_weekly_actual._value }} Act vs {{ hospital_doctor_needs_weekly_expected._rendered_value}} Exp)</p>
    {% elsif value > 0 or value < 0 %}
    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_weekly_actual._value }} Act vs {{ hospital_doctor_needs_weekly_expected._rendered_value}} Exp)</p>
    {% else %}
    <p style="color: black; background-color: white; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_weekly_actual._value }} Act vs {{ hospital_doctor_needs_weekly_expected._rendered_value}} Exp)</p>
    {% endif %}
    </a>
    ;;
    drill_fields: [drill*]
  }

  measure: hospital_doctor_needs_weekly_actual_vs_expected_perc_diff {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Weekly)"
    label: "4 - Hospital's Doctor Needs (Weekly) - % Difference"
    type: number
    sql: ${hospital_doctor_needs_weekly_actual_vs_expected_abs_diff} / nullif(${hospital_doctor_needs_weekly_actual},0) ;;
    value_format_name: percent_1
  }

### Hospital Expected Doctors (Annual)

  measure: hospital_doctor_needs_annual_actual {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Annual)"
    label: "1 - Hospital's Doctor Needs (Annual) - Actual"
    type: number
    sql: ${count} ;;
  }

  measure: hospital_doctor_needs_annual_expected {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Annual)"
    label: "2 - Hospital's Doctor Needs (Annual) - Expected"
    type: average
    sql: ${hospital_dimension.weekly_doctor_target} * 52 ;;
    value_format_name: decimal_0
  }

  measure: hospital_doctor_needs_annual_actual_vs_expected_abs_diff {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Annual)"
    label: "3 - Hospital's Doctor Needs (Annual) - Abs Difference"
    type: number
    sql: ${hospital_doctor_needs_annual_actual} - ${hospital_doctor_needs_annual_expected} ;;
    html:
      <a href="#drillmenu" target="_self">
      {% if value > 30 or value < -30 %}
      <p style="color: white; background-color: red; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_annual_actual._value }} Act vs {{ hospital_doctor_needs_annual_expected._rendered_value}} Exp)</p>
      {% elsif value > 20 or value < -20 %}
      <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_annual_actual._value }} Act vs {{ hospital_doctor_needs_annual_expected._rendered_value}} Exp)</p>
      {% elsif value > 10 or value < 10 %}
      <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_annual_actual._value }} Act vs {{ hospital_doctor_needs_annual_expected._rendered_value}} Exp)</p>
      {% elsif value > 5 or value < 5 %}
      <p style="color: white; background-color: green; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_annual_actual._value }} Act vs {{ hospital_doctor_needs_annual_expected._rendered_value}} Exp)</p>
      {% else %}
      <p style="color: black; background-color: white; font-size:100%; text-align:center">{{rendered_value}} ({{ hospital_doctor_needs_annual_actual._value }} Act vs {{ hospital_doctor_needs_annual_expected._rendered_value}} Exp)</p>
      {% endif %}
      </a>
    ;;
    drill_fields: [drill*]
  }

  measure: hospital_doctor_needs_annual_actual_vs_expected_perc_diff {
    view_label: "CNH"
    group_label: "Hospital's Doctor Needs (Annual)"
    label: "4 - Hospital's Doctor Needs (Annual) - % Difference"
    type: number
    sql: ${hospital_doctor_needs_annual_actual_vs_expected_abs_diff} / nullif(${hospital_doctor_needs_annual_actual},0) ;;
    value_format_name: percent_1
  }

### Doctor Annual Weeks

  measure: doctor_annual_weeks_actual {
    view_label: "CNH"
    group_label: "Doctor Annual Weeks"
    label: "1 - Doctor Annual Weeks - Actual"
    type: number
    sql: ${count} ;;
  }

  measure: doctor_annual_weeks_expected {
    view_label: "CNH"
    group_label: "Doctor Annual Weeks"
    label: "2 - Doctor Annual Weeks - Expected"
    type: average
    sql: ${doctor_weeks_required.expected_weeks_per_year} ;;
    value_format_name: decimal_0
  }

  measure: doctor_annual_weeks_actual_vs_expected_abs_diff {
    view_label: "CNH"
    group_label: "Doctor Annual Weeks"
    label: "3 - Doctor Annual Weeks - Abs Difference"
    type: number
    sql: ${doctor_annual_weeks_actual} - ${doctor_annual_weeks_expected} ;;
    html:
      <a href="#drillmenu" target="_self">
      {% if value == 0 %}
      <p style="color: white; background-color: green; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_annual_weeks_actual._value }} Act vs {{ doctor_annual_weeks_expected._rendered_value}} Exp)</p>
      {% elsif value > 4 or value < -4 %}
      <p style="color: white; background-color: red; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_annual_weeks_actual._value }} Act vs {{ doctor_annual_weeks_expected._rendered_value}} Exp)</p>
      {% elsif value > 2 or value < -2 %}
      <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_annual_weeks_actual._value }} Act vs {{ doctor_annual_weeks_expected._rendered_value}} Exp)</p>
      {% elsif value > 0 or value < 0 %}
      <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_annual_weeks_actual._value }} Act vs {{ doctor_annual_weeks_expected._rendered_value}} Exp)</p>
      {% else %}
      <p style="color: black; background-color: white; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_annual_weeks_actual._value }} Act vs {{ doctor_annual_weeks_expected._rendered_value}} Exp)</p>
      {% endif %}
      </a>
    ;;
    drill_fields: [drill*]
  }

  measure: doctor_annual_weeks_actual_vs_expected_perc_diff {
    view_label: "CNH"
    group_label: "Doctor Annual Weeks"
    label: "4 - Doctor Annual Weeks - % Difference"
    type: number
    sql: ${doctor_annual_weeks_actual_vs_expected_abs_diff} / nullif(${doctor_annual_weeks_actual},0) ;;
    value_format_name: percent_1
  }

### Doctor at Hospital Annual Weeks

  measure: doctor_at_hospital_annual_weeks_actual {
    view_label: "CNH"
    group_label: "Doctor at Hospital Annual Weeks"
    label: "1 - Doctor at Hospital Annual Weeks - Actual"
    type: number
    sql: ${count} ;;
  }

  measure: doctor_at_hospital_annual_weeks_expected {
    view_label: "CNH"
    group_label: "Doctor at Hospital Annual Weeks"
    label: "2 - Doctor at Hospital Annual Weeks - Expected"
    type: average
    sql: ${doctor_hospital_preferences.expected_weeks_per_year} ;;
    value_format_name: decimal_0
  }

  measure: doctor_at_hospital_annual_weeks_actual_vs_expected_abs_diff {
    view_label: "CNH"
    group_label: "Doctor at Hospital Annual Weeks"
    label: "3 - Doctor at Hospital Annual Weeks - Abs Difference"
    type: number
    sql: ${doctor_at_hospital_annual_weeks_actual} - ${doctor_at_hospital_annual_weeks_expected} ;;
    value_format_name: decimal_0
    html:
    <a href="#drillmenu" target="_self">
    {% if value == 0 %}
    <p style="color: white; background-color: green; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_at_hospital_annual_weeks_actual._value }} Act vs {{ doctor_at_hospital_annual_weeks_expected._rendered_value}} Exp)</p>
    {% elsif value > 4 or value < -4 %}
    <p style="color: white; background-color: red; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_at_hospital_annual_weeks_actual._value }} Act vs {{ doctor_at_hospital_annual_weeks_expected._rendered_value}} Exp)</p>
    {% elsif value > 2 or value < -2 %}
    <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_at_hospital_annual_weeks_actual._value }} Act vs {{ doctor_at_hospital_annual_weeks_expected._rendered_value}} Exp)</p>
    {% elsif value > 0 or value < 0 %}
    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_at_hospital_annual_weeks_actual._value }} Act vs {{ doctor_at_hospital_annual_weeks_expected._rendered_value}} Exp)</p>
    {% else %}
    <p style="color: black; background-color: white; font-size:100%; text-align:center">{{rendered_value}} ({{ doctor_at_hospital_annual_weeks_actual._value }} Act vs {{ doctor_at_hospital_annual_weeks_expected._rendered_value}} Exp)</p>
    {% endif %}
    </a>
    ;;
    drill_fields: [drill*]
  }

  measure: doctor_at_hospital_annual_weeks_actual_vs_expected_perc_diff {
    view_label: "CNH"
    group_label: "Doctor at Hospital Annual Weeks"
    label: "4 - Doctor at Hospital Annual Weeks - % Difference"
    type: number
    sql: ${doctor_at_hospital_annual_weeks_actual_vs_expected_abs_diff} / nullif(${doctor_at_hospital_annual_weeks_actual},0) ;;
    value_format_name: percent_1
  }
}



## Not Important

# dimension: doctors_still_needed_at_hospital_that_week {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.doctors_still_needed_at_hospital_that_week ;;
# }

# dimension: is_doctor_scheduled_that_week {
#   group_label: "Z"
#   type: yesno
#   sql: ${TABLE}.is_doctor_scheduled_that_week ;;
# }

# dimension: score_doctor_scheduled_that_week {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_doctor_scheduled_that_week ;;
# }

# dimension: score_doctors_still_needed_at_hospital_that_week {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_doctors_still_needed_at_hospital_that_week ;;
# }

# dimension: score_is_stationed_at_hospital {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_is_stationed_at_hospital ;;
# }

# dimension: score_status {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_status ;;
# }

# dimension: score_total {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_total ;;
# }

# dimension: score_weeks_still_needed_that_hospital_for_doctor {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_weeks_still_needed_that_hospital_for_doctor ;;
# }

# dimension: score_weeks_still_needed_total_for_doctor {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.score_weeks_still_needed_total_for_doctor ;;
# }

# dimension: weeks_still_needed_that_hospital_for_doctor {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.weeks_still_needed_that_hospital_for_doctor ;;
# }

# dimension: weeks_still_needed_total_for_doctor {
#   group_label: "Z"
#   type: number
#   sql: ${TABLE}.weeks_still_needed_total_for_doctor ;;
# }
