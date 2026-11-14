<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        
        DB::unprepared('DROP PROCEDURE IF EXISTS sp_ingresos_por_estilista');

        DB::unprepared("
            CREATE PROCEDURE sp_ingresos_por_estilista(IN p_desde DATE, IN p_hasta DATE)
            BEGIN
                DECLARE v_fin INT DEFAULT 0;
                DECLARE v_id BIGINT;
                DECLARE v_nombre VARCHAR(100);
                DECLARE v_total DECIMAL(10,2);

                
                DECLARE cur_estilistas CURSOR FOR
                    SELECT id, name FROM stylists WHERE active = 1;

                
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = 1;

               
                DROP TEMPORARY TABLE IF EXISTS tmp_ingresos;
                CREATE TEMPORARY TABLE tmp_ingresos (estilista VARCHAR(100), total DECIMAL(10,2));

                OPEN cur_estilistas;

                recorrer: LOOP
                    FETCH cur_estilistas INTO v_id, v_nombre;

                    IF v_fin = 1 THEN
                        LEAVE recorrer;
                    END IF;

                    
                    SELECT COALESCE(SUM(p.amount), 0) INTO v_total
                    FROM payments p
                    JOIN appointments a ON a.id = p.appointment_id
                    WHERE a.stylist_id = v_id
                      AND a.date BETWEEN p_desde AND p_hasta;

                    INSERT INTO tmp_ingresos VALUES (v_nombre, v_total);
                END LOOP;

                CLOSE cur_estilistas;

                SELECT * FROM tmp_ingresos ORDER BY total DESC;
            END
        ");
    }

    public function down()
    {
        DB::unprepared('DROP PROCEDURE IF EXISTS sp_ingresos_por_estilista');
    }
};