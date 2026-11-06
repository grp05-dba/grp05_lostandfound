-- Adapted from the owning group PDF; duplicate closing statement removed.
CREATE TABLE users (
   user_id SERIAL PRIMARY KEY,
   username VARCHAR(50) NOT NULL UNIQUE,
   email VARCHAR(255) NOT NULL UNIQUE,
   password_hash VARCHAR(255) NOT NULL,
   role VARCHAR(30) NOT NULL
      CHECK (role IN (
          'ADMIN',
          'STUDENT',
          'ACADEMIC_SUPERVISOR',
          'COMPANY_SUPERVISOR',
          'OJT_COORDINATOR'
      )),
   is_active BOOLEAN NOT NULL DEFAULT TRUE,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   deleted_at TIMESTAMP NULL
);

CREATE TABLE audit_log (
   audit_id SERIAL PRIMARY KEY,
   table_name VARCHAR(100) NOT NULL,
   action VARCHAR(30) NOT NULL,
   row_id INTEGER NOT NULL,
   action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   details JSONB NULL
);

CREATE TABLE students (
  student_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE
      REFERENCES users(user_id),
  student_number VARCHAR(30) NOT NULL UNIQUE,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50) NULL,
  course VARCHAR(100) NOT NULL,
  year_level INTEGER NOT NULL
        CHECK (year_level > 0),
     contact_number VARCHAR(20) NOT NULL,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     deleted_at TIMESTAMP NULL
);

CREATE TABLE companies (
   company_id SERIAL PRIMARY KEY,
   company_name VARCHAR(255) NOT NULL UNIQUE,
   industry VARCHAR(100) NOT NULL,
   address VARCHAR(255) NOT NULL,
   contact_number VARCHAR(20) NOT NULL,
   email VARCHAR(255) NOT NULL,
   is_partner BOOLEAN NOT NULL DEFAULT FALSE,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   deleted_at TIMESTAMP NULL
);

CREATE TABLE academic_supervisors (
   academic_sup_id SERIAL PRIMARY KEY,
   user_id INTEGER NOT NULL UNIQUE
       REFERENCES users(user_id),
   first_name VARCHAR(50) NOT NULL,
   last_name VARCHAR(50) NOT NULL,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   deleted_at TIMESTAMP NULL
);

CREATE TABLE company_supervisors (
   company_sup_id SERIAL PRIMARY KEY,
   user_id INTEGER NOT NULL UNIQUE
       REFERENCES users(user_id),
   company_id INTEGER NOT NULL
       REFERENCES companies(company_id),
   first_name VARCHAR(50) NOT NULL,
   last_name VARCHAR(50) NOT NULL,
   position VARCHAR(100) NOT NULL,
   contact_number VARCHAR(20) NOT NULL,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   deleted_at TIMESTAMP NULL
);

CREATE TABLE requirements (
  req_id SERIAL PRIMARY KEY,
     title VARCHAR(150) NOT NULL UNIQUE,
     description TEXT NULL,
     is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE ojt_applications (
  application_id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES students(student_id),
  company_id INTEGER NOT NULL REFERENCES companies(company_id),
  application_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) NOT NULL DEFAULT 'Pending'
     CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Withdrawn')),
  remarks TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,

     -- Added composite unique constraint
     UNIQUE (application_id, student_id, company_id)
);

CREATE TABLE student_requirements (
   student_req_id SERIAL PRIMARY KEY,
   student_id INTEGER NOT NULL
       REFERENCES students(student_id),
   req_id INTEGER NOT NULL
       REFERENCES requirements(req_id),
   verified_by_sup_id INTEGER NULL
       REFERENCES academic_supervisors(academic_sup_id),
   file_path VARCHAR(255) NULL,
   status VARCHAR(20) NOT NULL DEFAULT 'Pending'
       CHECK (status IN (
           'Pending', 'Submitted', 'Approved', 'Rejected'
       )),
   submission_date TIMESTAMP NULL,
   verified_at TIMESTAMP NULL,
   remarks TEXT NULL,
   UNIQUE (student_id, req_id)
);
CREATE TABLE ojt_placements (
  placement_id SERIAL PRIMARY KEY,
  application_id INTEGER NOT NULL UNIQUE,
  student_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  company_sup_id INTEGER NOT NULL
     REFERENCES company_supervisors(company_sup_id),
  academic_sup_id INTEGER NOT NULL
     REFERENCES academic_supervisors(academic_sup_id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  required_hours NUMERIC(6,2) NOT NULL
     CHECK (required_hours > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'Pending'
     CHECK (status IN ('Pending', 'Active', 'Completed', 'Terminated')),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,

     -- Added composite foreign key
     CONSTRAINT fk_placement_application_consistency
        FOREIGN KEY (application_id, student_id, company_id)
        REFERENCES ojt_applications
          (application_id, student_id, company_id),

     CHECK (start_date <= end_date)
);




CREATE TABLE attendance (
  attendance_id SERIAL PRIMARY KEY,
  placement_id INTEGER NOT NULL
     REFERENCES ojt_placements(placement_id),
  attendance_date DATE NOT NULL,
  time_in TIME NULL,
  time_out TIME NULL,
  hours_rendered NUMERIC(5,2) NOT NULL DEFAULT 0
     CHECK (hours_rendered >= 0),
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (placement_id, attendance_date),
  CHECK (
     time_in IS NULL OR time_out IS NULL
         OR time_out >= time_in
     )
);

CREATE TABLE evaluations (
   evaluation_id SERIAL PRIMARY KEY,
   placement_id INTEGER NOT NULL
      REFERENCES ojt_placements(placement_id),
   company_sup_id INTEGER NOT NULL
      REFERENCES company_supervisors(company_sup_id),
   score NUMERIC(5,2) NOT NULL
      CHECK (score >= 0 AND score <= 100),
   feedback TEXT NULL,
   evaluation_date DATE NOT NULL DEFAULT CURRENT_DATE,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Local compatibility additions required by system/Db.java.
ALTER TABLE academic_supervisors ADD COLUMN employee_number VARCHAR(50), ADD COLUMN department VARCHAR(100), ADD COLUMN contact_number VARCHAR(20);
ALTER TABLE company_supervisors ADD COLUMN department VARCHAR(100);
