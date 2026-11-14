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
    Schema::create('service_stylist', function (Blueprint $table) {
        $table->id();
        $table->foreignId('service_id')->constrained();
        $table->foreignId('stylist_id')->constrained();
        $table->unique(['service_id', 'stylist_id']);
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
        Schema::dropIfExists('service_stylist');
    }
};
