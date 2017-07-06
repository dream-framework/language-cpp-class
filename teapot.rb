
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "2.0"

define_target "language-cpp-class" do |target|
	target.description = <<-EOF
		Generates a basic class file in the project.
		
		usage: teapot generate class Namespace::ClassName
	EOF
	
	target.depends "Generate/Template"
	target.provides "Generate/C++/Class"
	
	def target.scope_for_namespace(namespace)
		open = namespace.collect{|name| "namespace #{name}\n{\n"}
		close = namespace.collect{ "}\n" }
	
		return open + close
	end
	
	target.build do |class_name|
		*path, class_name = class_name.split(/::/)
		
		if path == []
			raise ArgumentError.new("You must specify a class name with a namespace!")
		end
		
		directory = Files::Path.new('source') + path.join('/')
		directory.mkpath
		
		name = Build::Name.new(class_name)
		substitutions = target.context.substitutions.dup
		
		# e.g. Foo Bar, typically used as a title, directory, etc.
		substitutions['CLASS_NAME'] = name.identifier
		substitutions['CLASS_FILE_NAME'] = name.identifier
		
		# e.g. FooBar, typically used as a namespace.
		substitutions['GUARD_NAME'] = name.macro(path) + '_H'
		
		# e.g. foo-bar, typically used for targets, executables.
		substitutions['NAMESPACE'] = target.scope_for_namespace(path)
		
		source_path = Build::Files::Directory.new(target.package.path + "templates/class")
		generate source: source_path, prefix: directory, substitutions: substitutions
	end
end

define_configuration "language-cpp-class" do |configuration|
	configuration.public!
	
	configuration.require "generate-template"
end
