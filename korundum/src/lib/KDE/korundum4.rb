=begin
/***************************************************************************
                          Korundum.rb  -  KDE specific ruby runtime, dcop etc.
                             -------------------
    begin                : Sun Sep 28 2003
    copyright            : (C) 2003-2004 by Richard Dale
    email                : Richard_Dale@tipitina.demon.co.uk
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
=end

module KDE
	
	def CmdLineArgs::init(*k)
		if k.length > 0 and k[0].kind_of?(Array)
			# If init() is passed an array as the first argument, assume it's ARGV.
			# Then convert to a pair of args 'ARGV.length+1, [$0]+ARGV'
			array = k.shift
			super(*([array.length+1] + [[$0] + array] + k))
		else
			super
		end
	end
	
	# A sane alternative to the strange looking C++ template version,
	# this takes a variable number of ruby args as classes to restore
	def MainWindow::kRestoreMainWindows(*k)
		n = 1
		while MainWindow.canBeRestored(n)
			className = MainWindow.classNameOfToplevel(n)
			k.each do |klass|
				if klass.name == className
					klass.new.restore(n)
				end
			end
			n += 1
		end
	end
	
	class Application
		def initialize(*k)
			super
			$kapp = self
		end
		
		# Delete the underlying C++ instance after exec returns
		# Otherwise, rb_gc_call_finalizer_at_exit() can delete
		# stuff that KDE::Application still needs for its cleanup.
		def exec
			super
			self.dispose
			Qt::Internal.application_terminated = true
		end
	end
	
	class UniqueApplication
		def initialize(*k)
			super
			$kapp = self
		end
		
		def exec
			super
			self.dispose
			Qt::Internal.application_terminated = true
		end
	end
	
	class AboutData
		def inspect
			str = super
			str.sub!(/>$/, " appName=%s, copyrightStatement=%s, programName=%s, version=%s, shortDescription=%s, homepage=%s, bugAddress=%s>" %
							[appName.inspect, copyrightStatement.inspect, programName.inspect, version.inspect,
							shortDescription.inspect, homepage.inspect, bugAddress.inspect] )
			length = authors.length
			if length > 0
				str.sub!(/>$/, ", authors=Array (%d element(s))>" % length)
			end
			length = credits.length
			if length > 0
				str.sub!(/>$/, ", credits=Array (%d element(s))>" % length)
			end
			length = translators.length
			if length > 0
				str.sub!(/>$/, ", translators=Array (%d element(s))>" % length)
			end
			return str
		end
		
		def pretty_print(pp)
			str = to_s
			str.sub!(/>$/, "\n appName=%s,\n copyrightStatement=%s,\n programName=%s,\n version=%s,\n shortDescription=%s,\n homepage=%s,\n bugAddress=%s>" % 
							[appName.inspect, copyrightStatement.inspect, programName.inspect, version.inspect,
							shortDescription.inspect, homepage.inspect, bugAddress.inspect] )
			length = authors.length
			if length > 0
				str.sub!(/>$/, ",\n authors=Array (%d element(s))>" % length)
			end
			length = credits.length
			if length > 0
				str.sub!(/>$/, ",\n credits=Array (%d element(s))>" % length)
			end
			length = translators.length
			if length > 0
				str.sub!(/>$/, ",\n translators=Array (%d element(s))>" % length)
			end
			pp.text str
		end
	end
	
	class AboutPerson
		def inspect
			str = super
			str.sub(/>$/, " emailAddress=%s, name=%s, task=%s, webAddress=%s>" % 
						[emailAddress.inspect, name.inspect, task.inspect, webAddress.inspect] )
		end
		
		def pretty_print(pp)
			str = to_s
			pp.text str.sub(/>$/, "\n emailAddress=%s,\n name=%s,\n task=%s,\n webAddress=%s>" % 
						[emailAddress.inspect, name.inspect, task.inspect, webAddress.inspect] )
		end
	end
	
	class AboutTranslator
		def inspect
			str = super
			str.sub(/>$/, " emailAddress=%s, name=%s>" % 
						[emailAddress.inspect, name.inspect] )
		end
		
		def pretty_print(pp)
			str = to_s
			pp.text str.sub(/>$/, "\n emailAddress=%s,\n name=%s>" % 
						[emailAddress.inspect, name.inspect] )
		end
	end
	
	class Service
		def inspect
			str = super
			str.sub(/>$/, " library=%s, type=%s, name=%s>" % [library.inspect, type.inspect, name.inspect])
		end
		
		def pretty_print(pp)
			str = to_s
			pp.text str.sub(/>$/, "\n library=%s,\n type=%s,\n name=%s>" % [library.inspect, type.inspect, name.inspect])
		end
	end
	
	class URL
		def inspect
			str = super
			str.sub(/>$/, " url=%s, protocol=%s, host=%s, port=%d>" % [url.inspect, protocol.inspect, host.inspect, port])
		end
		
		def pretty_print(pp)
			str = to_s
			pp.text str.sub(/>$/, "\n url=%s,\n protocol=%s,\n host=%s,\n port=%d>" % [url.inspect, protocol.inspect, host.inspect, port])
		end
	end
end

class Object
	def RESTORE(klass)
		n = 1
		while MainWindow.canBeRestored(n)
			klass.new.restore(n)
			n += 1
		end
	end

	def I18N_NOOP(x) x end
	def I18N_NOOP2(comment, x) x end
end

