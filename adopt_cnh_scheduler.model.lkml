connection: "cloudadopt"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: input_loop_table_final {
  view_label: "CNH"
  label: "CNH Scheduler"

  sql_always_where: ${loop_id} is not null ;;

  join: doctor_hospital_preferences {
    relationship: many_to_one
    sql_on:
          ${input_loop_table_final.hospital_id} = ${doctor_hospital_preferences.hospital_id}
      AND ${input_loop_table_final.doctor_id} = ${doctor_hospital_preferences.doctor_id}
    ;;
  }

  join: doctor_weeks_required {
    relationship: many_to_one
    sql_on:
          ${input_loop_table_final.doctor_id} = ${doctor_weeks_required.doctor_id}
    ;;
  }

  join: hospital_dimension {
    relationship: many_to_one
    sql_on:
          ${input_loop_table_final.hospital_id} = ${hospital_dimension.hospital_id}
    ;;
  }
}
