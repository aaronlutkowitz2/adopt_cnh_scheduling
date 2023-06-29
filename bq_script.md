/******************
Aaron Wilkowitz
ADOPT - Children's National
Script to Build Hill Climber
2023-02-16
******************/

/******************
Create input table
Note: update the run id
******************/

CREATE OR REPLACE TABLE `cloudadopt.cnh_scheduling.input_loop_table_run1` AS
SELECT * FROM `cloudadopt.cnh_scheduling.input_loop_table_pre`
;

/******************
Run Loop
******************/

# Set start & stop loop values
CREATE OR REPLACE TABLE `cloudadopt.cnh_scheduling.set_loops` AS
SELECT 0 as start_loop_id, sum(weekly_doctor_target) * 52 as end_loop_id
FROM `cloudadopt.cnh_scheduling.hospital_dimension`
;

# Start loop
LOOP
  # Add 1 to loop
  UPDATE `cloudadopt.cnh_scheduling.set_loops` SET start_loop_id = start_loop_id + 1 WHERE 1 = 1 ;

  # Check that we should still run loop
  IF (SELECT start_loop_id FROM `cloudadopt.cnh_scheduling.set_loops`) > (SELECT end_loop_id FROM `cloudadopt.cnh_scheduling.set_loops`) THEN
    LEAVE;
  ELSE

  # Calculate each score
  CREATE OR REPLACE TABLE `cloudadopt.cnh_scheduling.input_loop_table_run1` AS
  with dataset1 as (
    SELECT
        * except(score_doctor_scheduled_that_week, score_doctors_still_needed_at_hospital_that_week, score_status, score_weeks_still_needed_total_for_doctor, score_weeks_still_needed_that_hospital_for_doctor, score_is_stationed_at_hospital, score_total)

      # if doctor is scheduled that week, give it many, many negative points - it's impossible
      , case when is_doctor_scheduled_that_week then pow(10,10) * -1 else 0 end as score_doctor_scheduled_that_week

      # if main campus, take # doctors still needed * 10000; if community site, take # doctors still needed * 15000
      , case when is_main_campus then doctors_still_needed_at_hospital_that_week * pow(10,5) else doctors_still_needed_at_hospital_that_week * pow(10,5) * 1.5 end as score_doctors_still_needed_at_hospital_that_week

      # if CME, give it negative 10^7; if vacation, give it negative points based on vacation ranking; if it's free, give it positive 1000
      , case
          when request_status = 'CME' then pow(10,7) * -1
          when request_status = 'Vacation #1' then pow(10,6) * -1
          when request_status = 'Vacation #2' then pow(10,5) * -1
          when request_status = 'Vacation #3' then pow(10,3) * -1
          when request_status = 'Vacation #4' then pow(10,2) * -1
          when request_status = 'Vacation #5' then pow(10,1) * -1
          else pow(10,3)
        end as score_status

      # take total # of weeks doctor needs and add 1000 per hour
      , weeks_still_needed_total_for_doctor * pow(10,3) as score_weeks_still_needed_total_for_doctor

      # take total # of weeks doctor needs at a specific hospital and add 10k per hour
      , weeks_still_needed_that_hospital_for_doctor * pow(10,5) as score_weeks_still_needed_that_hospital_for_doctor

      # if doctor is normally stationed at hospital, give positive 1000, otherwise give negative 10^7
      , case when is_stationed_at_hospital then pow(10,3) else pow(10,7) * -1 end as score_is_stationed_at_hospital

    FROM `cloudadopt.cnh_scheduling.input_loop_table_run1`
  )
  SELECT
      *
    , score_doctor_scheduled_that_week + score_doctors_still_needed_at_hospital_that_week + score_status + score_weeks_still_needed_total_for_doctor + score_weeks_still_needed_that_hospital_for_doctor + score_is_stationed_at_hospital as score_total
  FROM dataset1
  ;

  # Narrow down to top score
  CREATE OR REPLACE TABLE `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` AS
  SELECT
      pk_id
    , hospital_id
    , doctor_id
    , date
  FROM `cloudadopt.cnh_scheduling.input_loop_table_run1`
  ORDER BY score_total desc
  LIMIT 1
  ;

  # Update values
  CREATE OR REPLACE TABLE `cloudadopt.cnh_scheduling.input_loop_table_run1` AS
  SELECT
      a.* except (loop_id, loop_score, is_doctor_scheduled_that_week, doctors_still_needed_at_hospital_that_week, weeks_still_needed_total_for_doctor, weeks_still_needed_that_hospital_for_doctor)
    , case when c.pk_id is not null then b.start_loop_id else a.loop_id end as loop_id
    , case when c.pk_id is not null then a.score_total else a.loop_score end as loop_score
    , case when d.pk_id is not null then TRUE else a.is_doctor_scheduled_that_week end as is_doctor_scheduled_that_week
    , case when e.pk_id is not null then a.doctors_still_needed_at_hospital_that_week - 1 else a.doctors_still_needed_at_hospital_that_week end as doctors_still_needed_at_hospital_that_week
    , case when f.pk_id is not null then a.weeks_still_needed_total_for_doctor - 1 else a.weeks_still_needed_total_for_doctor end as weeks_still_needed_total_for_doctor
    , case when g.pk_id is not null then a.weeks_still_needed_that_hospital_for_doctor - 1 else a.weeks_still_needed_that_hospital_for_doctor end as weeks_still_needed_that_hospital_for_doctor
  FROM `cloudadopt.cnh_scheduling.input_loop_table_run1` a
  , `cloudadopt.cnh_scheduling.set_loops` b
  LEFT JOIN `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` c
    ON a.pk_id = c.pk_id
  LEFT JOIN `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` d
    ON a.date = d.date
  LEFT JOIN `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` e
    ON a.hospital_id = e.hospital_id
    AND a.date = e.date
  LEFT JOIN `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` f
    ON a.doctor_id = f.doctor_id
  LEFT JOIN `cloudadopt.cnh_scheduling.input_loop_table_run1_top_score` g
    ON a.doctor_id = g.doctor_id
    AND a.hospital_id = g.hospital_id
  ;

  END IF;

END LOOP;
