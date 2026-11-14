<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */

    public function up()
    {
    Schema::create('appointment_service', function (Blueprint $table) {
        $table->id();
        $table->foreignId('appointment_id')->constrained();
        $table->foreignId('service_id')->constrained();
        $table->decimal('price', 10, 2);
        $table->unique(['appointment_id', 'service_id']);
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('appointment_service');
    }
};
