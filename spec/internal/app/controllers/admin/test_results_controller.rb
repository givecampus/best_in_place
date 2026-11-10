class Admin::TestResultsController < ApplicationController

  def create
    test_result = TestResult.new test_result_params
    if test_result.save
      render json: test_result, root: true
    else
      render json: test_result.errors.full_messages, status: 422
    end
  end

  def update
    @test_result = TestResult.find(params[:id])
    @test_result.update(test_result_params)
    respond_to do |format|
      format.json { respond_with_bip(@test_result) }
    end
  end

  private

  def test_result_params
    params[:test_result].permit!
  end
end
