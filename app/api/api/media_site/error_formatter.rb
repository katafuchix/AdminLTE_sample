module MediaSite
  module ErrorFormatter
    # error!メソッド実行時にJSONを出力する
    # 5つのパラメーターが渡されるのでそれを元にエラー出力
    # @param [Object] message メッセージまたはメッセージ+エラーコードのHash
    # @param [Array] _backtrace backtrace
    # @param [Hash] _options options
    # @params [Symbol] _env env
    # @params [不明] _other
    # @return [String] JSON文字列
    def self.call(message, _backtrace, _options, _env, _other)
      if message.is_a?(Hash)
        { result: false }.merge(message).to_json
      else
        { result: false, message: message }.to_json
      end
    end
  end
end
