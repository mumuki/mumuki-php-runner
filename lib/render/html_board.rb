require "base64"

module Php
  class HtmlBoard
    attr_reader :gbb, :boom

    def initialize(board, boom = false)
      @gbb = board[:table][:gbb]
      @boom = boom
    end
  end
end
