module Api
    class SurvivorController < ApplicationController
        
        dif index
            Survivor = Survivor.all
            render json: { status: 'SUCCESS', message: 'List of survivors', data: survivors }, status: :ok
    end

    # GET
    def show
        survivor = Survivor.find(params[:id])
        render json: { status: 'SUCCESS', message: 'Successfully found survivor record', survivor: }, status: :ok
    rescue StandardError => e
        render json: { status: 'ERROR', message: 'Could not find survivor record with id: #{params[:id]}' },
            status: :not_found
    end

    # POST
    def create
        survivor = Survivor.new(survivor_params)
        survivor.save
        render json: { status: 'SUCCESS', message: 'Succesfully created survivor', survivor},
            status: :created
    else
        render json: { status: 'ERROR',  message: 'Unable to create a Survivor' }, status: :unprocessable_entity
    end
    rescue StandardError => e
    render json: { status: 'ERROR', message: 'Unable to create a Survivor' }, status: :unprocessable_entity
  end

  # PUT
  def location
    survivor = Survivor.find(params[:id])
    if survivor.update(survivor_location_params)
        render json: { status: 'SUCCESS', message: 'Unable to update Survivor location', data: survivor.errors },
            status :unprocessable_entity
  end
 end

  # PUT
  def infected
    survivor = Survivor.find(params[:id])

    numInfections = survivor[:infectionCount]
    numInfections += 1

    if survivor.update(infectionCount: numInfections)
        if numInfections >= 5
            survivor.update(infected: true)
            render json: {status: 'SUCCESS', message: 'Updated survivor infection status, survivor is infected', name: survivor[:name], infectionCount: survivor[:infectionCount], infected: survivor[:infected] },
                status: :ok
        end
    else
        render json: {status: 'SUCCESS', message: 'Updated survivor infection status, survivor is not infected', name: survivor[:name], infectionCount: survivor[:infectionCount], infected: survivor[:infected] },
        status: :ok
    end
 else
    render json: { status: 'ERROR', message: 'Unable to update survivor infection status', data: @survivor.errors },
           status: :unprocessable_entity
  end
end

# POST
def trade
    tradingValues = {
        'water' => 14,
        'soup' => 12,
        'firstAid' => 10,
        'ak47' => 8
    }

    buyer = Survivor.find(survivor_trade_params[:buyerId])
    seller = Survivor.find(survivor_trade_params[:sellerId])

    if isInfected(buyer[:infected], seller[:infected]) == false
        if hasItems(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell]) == true
            
            if validTrade(buyer, seller, survivor_trade_params[:itemsToBuy], survivor_trade_params[:itemsToSell],
                          tradeValues) == true
              render json: { status: 'SUCCESS', message: 'Successful trade', buyerPoints: @buyerSum, sellerPoints: @sellerSum, buyerInventoryChange: @updatedBuyerInventory.merge(id: buyer[:id], name: buyer[:name]), sellerInventoryChange: @updatedSellerInventory.merge(id: seller[:id], name: seller[:name]) },
                     status: :ok
            else
              render json: { status: 'ERROR', message: 'unsuccessful trade because buyer and seller points do not match', buyerPoints: @buyerSum, sellerPoints: @sellerSum },
                     status: :bad_request
            end
          else
            render json: { status: 'ERROR', message: 'Unsuccessful trade because buyer or seller does not have so many items' },
                   status: :bad_request
          end
        else
          render json: { status: 'ERROR', message: 'Unsuccessful trade because buyer or seller is infected and their inventory is locked' },
                 status: :bad_request
        end
      end