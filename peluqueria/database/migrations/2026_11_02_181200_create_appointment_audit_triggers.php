<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        
        DB::unprepared("
            CREATE TRIGGER trg_appointments_after_insert
            AFTER INSERT ON appointments
            FOR EACH ROW
            BEGIN
                INSERT INTO audits (table_name, record_id, action, old_status, new_status)
                VALUES ('appointments', NEW.id, 'crear', NULL, NEW.status);
            END
        ");

        
        DB::unprepared("
            CREATE TRIGGER trg_appointments_after_update
            AFTER UPDATE ON appointments
            FOR EACH ROW
            BEGIN
                DECLARE v_accion VARCHAR(20);

                IF NEW.status = 'cancelado' AND OLD.status <> 'cancelado' THEN
                    SET v_accion = 'cancelar';
                ELSEIF NEW.status = 'atendido' AND OLD.status <> 'atendido' THEN
                    SET v_accion = 'atender';
                ELSE
                    SET v_accion = 'modificar';
                END IF;

                INSERT INTO audits (table_name, record_id, action, old_status, new_status)
                VALUES ('appointments', NEW.id, v_accion, OLD.status, NEW.status);
            END
        ");
    }

    public function down()
    {
        DB::unprepared('DROP TRIGGER IF EXISTS trg_appointments_after_insert');
        DB::unprepared('DROP TRIGGER IF EXISTS trg_appointments_after_update');
    }
};