class Manifest
  ASSETS = {
    'common.css' => 'style',
    'common.js' => 'script',
  }.freeze

  def initialize(path)
    @manifest = JSON.parse(File.read(path))
  end

  def call(env)
    [399, override_headers(env), []]
  end

  private

  def override_headers(env = {})
    return {} if env['REQUEST_METHOD']&.downcase != 'get'

    accepts = env['HTTP_ACCEPT']&.split(/,\s*/) || []
    return {} unless accepts.include?('text/html')

    path = env['PATH_INFO'] || '/'
    return {} unless path =~ %r{\A/(?:(?:about|terms|users|web|@[^/]+)/?|\z)}

    push_paths = @manifest.select { |name, _| ASSETS.has_key?(name) }
    { 'link' => push_paths.map { |name, path| "<#{path}>; rel=preload; as=#{ASSETS[name]}" }.join("\n") }
  end
end

Manifest.new('/var/www/html/packs/manifest.json')
