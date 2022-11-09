module Api
    class SurvivorController < ApplicationController
        
        dif index
            Survivor = Survivor.all
            render json: { status: 'SUCCESS', message: 'List of survivors', data: survivors }, status: :ok
    end

    def show
        survivor = Survivor.find(params[:id])
        render json: { status: 'SUCCESS', message: 'Successfully found survivor record', survivor: }, status: :ok
    rescue StandardError => e
        render json: { status: 'ERROR', message: 'Could not find survivor record with id: #{params[:id]}' },
            status: :not_found
    end

    