class Manifest
  DEFAULT_ASSETS = %w(
    common.css
    common.js
  ).freeze

  ASSET_TYPES = {
    '' => 'fetch',
    '.css' => 'style',
    '.svg' => 'image',
    '.js' => 'script',
    '.png' => 'image',
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

    path = env['PATH_INFO']
    return {} if path.nil? || %r{\A/(?:\z|(?:about|terms|users|web|@[^/]+)/?)} !~ path

    push_paths = @manifest.select { |name, _| DEFAULT_ASSETS.include?(name) }.values

    if %r{\A/about/?\z} =~ path
      push_paths << @manifest['about.js']
      push_paths << @manifest['elephant-fren.png']
      push_paths << @manifest['logo_full.svg']
      push_paths << '/api/v1/timelines/public'
    end

    if %r{\A/(?:about/more|(?:terms|users|@[^/]+))(?:/|\z)} =~ path
      push_paths << @manifest['public.js']
    end

    if %r{\A/(?:\z|web/)} =~ path
      push_paths << @manifest['application.js']
      push_paths << @manifest['features/getting_started.js']
      push_paths << @manifest['features/compose.js']
      push_paths << @manifest['features/home_timeline.js']
      push_paths << @manifest['features/notifications.js']
      push_paths << @manifest['mastodon-getting-started.png']
      push_paths << '/api/v1/timelines/public'
    end

    { 'link' => push_paths.map { |path| "<#{path}>; rel=preload; as=#{ASSET_TYPES[File.extname(path)]}" }.join("\n") }
  end
end

Manifest.new('/var/www/html/packs/manifest.json')
