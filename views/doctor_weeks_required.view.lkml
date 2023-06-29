view: doctor_weeks_required {
  sql_table_name: `cloudadopt.cnh_scheduling.doctor_weeks_required`
    ;;

  dimension: doctor_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.doctor_id ;;
  }

  dimension: expected_weeks_per_year {
    hidden: yes
    type: number
    sql: ${TABLE}.expected_weeks_per_year ;;
  }
}


# dimension: first_name {
#   type: string
#   sql: ${TABLE}.first_name ;;
# }

# dimension: last_name {
#   type: string
#   sql: ${TABLE}.last_name ;;
# }

# measure: count {
#   type: count
#   drill_fields: [last_name, first_name]
# }
