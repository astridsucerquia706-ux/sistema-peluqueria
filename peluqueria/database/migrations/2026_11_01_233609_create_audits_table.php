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
    Schema::create('audits', function (Blueprint $table) {
        $table->id();
        $table->string('table_name', 50);
        $table->foreignId('record_id')->constrained('appointments');
        $table->string('action', 20);
        $table->string('old_status', 20)->nullable();
        $table->string('new_status', 20)->nullable();
        $table->timestamp('created_at')->useCurrent();
    });
    }
    
    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('audits');
    }
};
