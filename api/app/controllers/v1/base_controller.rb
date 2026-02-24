module V1
  class BaseController < ApplicationController
    private

    def render_payload(payload)
      render json: payload
    end
  end
end
