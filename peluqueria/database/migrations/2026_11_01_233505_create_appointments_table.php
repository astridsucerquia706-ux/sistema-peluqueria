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
    Schema::create('appointments', function (Blueprint $table) {
        $table->id();
        $table->foreignId('client_id')->constrained();
        $table->foreignId('stylist_id')->constrained();
        $table->foreignId('user_id')->constrained();
        $table->date('date');
        $table->time('time');
        $table->string('status', 20)->default('pendiente');
        $table->string('notes', 255)->nullable();
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
        Schema::dropIfExists('appointments');
    }
};
