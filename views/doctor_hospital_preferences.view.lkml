view: doctor_hospital_preferences {
  sql_table_name: `cloudadopt.cnh_scheduling.doctor_hospital_preferences`
    ;;

  dimension: pk {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${doctor_id} || '-' || ${hospital_id} ;;
  }

  dimension: doctor_id {
    hidden: yes
    type: number
    sql: ${TABLE}.doctor_id ;;
  }

  dimension: hospital_id {
    hidden: yes
    type: number
    sql: ${TABLE}.hospital_id ;;
  }

  dimension: expected_weeks_per_year {
    hidden: yes
    type: number
    sql: ${TABLE}.expected_weeks_per_year ;;
  }
}

# dimension: hospital_code {
#   type: string
#   sql: ${TABLE}.hospital_code ;;
# }

# dimension: is_stationed_at_hospital {
#   type: yesno
#   sql: ${TABLE}.is_stationed_at_hospital ;;
# }

# measure: count {
#   type: count
#   drill_fields: []
# }
