module Ufo
  class Docker < Command
    autoload :Help, 'ufo/docker/help'

    desc "build", "builds docker image"
    long_desc Help.build
    option :push, type: :boolean, default: false
    def build
      builder = DockerBuilder.new(options)
      builder.build
      builder.push if options[:push]
    end

    desc "base", "builds docker image from Dockerfile.base and update current Dockerfile"
    long_desc Help.base
    option :push, type: :boolean, default: true
    def base
      builder = DockerBuilder.new(options.dup.merge(
        image_namespace: "base",
        dockerfile: "Dockerfile.base"
      ))
      builder.build
      builder.push if options[:push]
      builder.update_dockerfile
      DockerCleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
      EcrCleaner.new(builder.image_name, options.merge(tag_prefix: "base")).cleanup
    end

    desc "image_name", "displays the full docker image with tag that will be generated"
    option :generate, type: :boolean, default: false, desc: "Generate a name without storing it"
    long_desc Help.full_image_name
    def image_name
      full_image_name = DockerBuilder.new(options).full_image_name
      puts full_image_name
    end

    desc "cleanup IMAGE_NAME", "Cleans up old images.  Keeps a specified amount."
    option :keep, type: :numeric, default: 3
    option :tag_prefix, default: "ufo"
    long_desc Help.cleanup
    def cleanup(image_name)
      DockerCleaner.new(image_name, options).cleanup
    end
  end
end
