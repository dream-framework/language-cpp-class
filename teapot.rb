
#
#  This file is part of the "Teapot" project, and is released under the MIT license.
#

teapot_version "1.0.0"

define_generator "Library/C++/class" do |generator|
	generator.description = <<-EOF
		Generates a basic class file in the project.
		
		usage: teapot generate class Namespace::ClassName
	EOF
	
	def scope_for_namespace(namespace)
		open = namespace.collect{|name| "namespace #{name}\n{\n"}
		close = namespace.collect{ "}\n" }
	
		return open + close
	end
	
	generator.generate do |class_name|
		*path, class_name = class_name.split(/::/)
		
		if path == []
			raise GeneratorError.new("You must specify a class name with a namespace!")
		end
		
		directory = Pathname('source') + path.join('/')
		directory.mkpath
		
		name = Name.new(class_name)
		substitutions = Substitutions.new
		
		# e.g. Foo Bar, typically used as a title, directory, etc.
		substitutions['CLASS_NAME'] = name.identifier
		substitutions['CLASS_FILE_NAME'] = name.identifier
		
		# e.g. FooBar, typically used as a namespace
		substitutions['GUARD_NAME'] = name.macro(path) + '_H'
		
		# e.g. foo-bar, typically used for targets, executables
		substitutions['NAMESPACE'] = scope_for_namespace(path)
		
		# The user's current name:
		substitutions['AUTHOR_NAME'] = `git config --global user.name`.chomp!
		
		substitutions['PROJECT_NAME'] = context.project.name
		substitutions['LICENSE'] = context.project.license
		
		current_date = Time.new
		substitutions['DATE'] = current_date.strftime("%-d/%-m/%Y")
		substitutions['YEAR'] = current_date.strftime("%Y")
		
		generator.copy('templates/class', directory, substitutions)
	end
end

define_configuration 'language-cpp-class' do
end
