module V1x0Helper
  def api_version
    File.join('/', ENV['PATH_PREFIX'], ENV['APP_NAME'], 'v1.0')
  end
end
