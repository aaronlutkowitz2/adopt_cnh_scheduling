view: hospital_dimension {
  sql_table_name: `cloudadopt.cnh_scheduling.hospital_dimension`
    ;;

  dimension: hospital_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.hospital_id ;;
  }

  dimension: weekly_doctor_target {
    hidden: yes
    type: number
    sql: ${TABLE}.weekly_doctor_target ;;
  }
}


# dimension: hospital_code {
#   type: string
#   sql: ${TABLE}.hospital_code ;;
# }

# dimension: hospital_name {
#   type: string
#   sql: ${TABLE}.hospital_name ;;
# }

# dimension: is_main_campus {
#   type: yesno
#   sql: ${TABLE}.is_main_campus ;;
# }

# measure: count {
#   type: count
#   drill_fields: [hospital_name]
# }
