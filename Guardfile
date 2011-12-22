guard 'shell'  do
  jasmine_node_bin = File.expand_path(File.dirname(__FILE__) + "/node_modules/jasmine-node/lib/jasmine-node/cli.js")

  watch(%r{^(.+)\.coffee})  { |m| `node #{jasmine_node_bin} --coffee spec` }
end

