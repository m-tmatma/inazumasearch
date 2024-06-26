# get assembly version
asmLines = File.readlines('InazumaSearch/Properties/AssemblyInfo.cs', encoding: 'utf-8')
version = nil
asmLines.each do |line|
	if line =~ /\[assembly\: AssemblyVersion\("(\d+\.\d+\.\d+)\.0"\)\]/ then
		version = $1
	end
end

unless asmLines
	$stderr.puts "AssemblyVersion not found."
	return
end

MSBUILD = 'C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe'
EXEPRESS = 'C:\\Program Files (x86)\\OPTPiX\\EXEpress 6\\EXEpress.exe'

PLATFORMS = ['x86', 'x64']

DEST_EXES = {}
DEST_EXES['x86'] = "out/InazumaSearch-#{version}-x86.exe"
DEST_EXES['x64'] = "out/InazumaSearch-#{version}-x64.exe"
EXEPRESS_INIS = {}
EXEPRESS_INIS['x86'] = "out/InazumaSearch_exepress_#{version}_x86.ini"
EXEPRESS_INIS['x64'] = "out/InazumaSearch_exepress_#{version}_x64.ini"

DEST_ZIPS = {}
DEST_ZIPS['x86'] = "out/InazumaSearch-#{version}-x86.zip"
DEST_ZIPS['x64'] = "out/InazumaSearch-#{version}-x64.zip"
DEST_CABS = {}
PLATFORMS.each do |platform|
	DEST_CABS[platform] = DEST_ZIPS[platform].sub(/zip$/, 'cab')
end
DEST_ZIPS_PORTABLE = {}
DEST_ZIPS_PORTABLE['x86'] = "out/InazumaSearch-#{version}-Portable-x86.zip"
DEST_ZIPS_PORTABLE['x64'] = "out/InazumaSearch-#{version}-Portable-x64.zip"

RELEASE_EXE = {}
RELEASE_EXE['x86'] = "InazumaSearch/bin/Release/x86/InazumaSearch.exe"
RELEASE_EXE['x64'] = "InazumaSearch/bin/Release/x64/InazumaSearch.exe"
RELEASE_PORTABLE_EXE = {}
RELEASE_PORTABLE_EXE['x86'] = "InazumaSearch/bin/Release_Portable/x86/program/InazumaSearch.exe"
RELEASE_PORTABLE_EXE['x64'] = "InazumaSearch/bin/Release_Portable/x64/program/InazumaSearch.exe"

SRCS = FileList['InazumaSearch/**/*']
SRCS.exclude('InazumaSearch/bin/**/*')
SRCS.exclude('InazumaSearch/obj/**/*')

OUTDIR = 'out'
directory OUTDIR

task :default => ['exe', 'zip:portable']

desc "-"
task 'exe' => DEST_EXES.values

desc "-"
task 'cab:standard' => DEST_CABS.values

desc "-"
task 'zip:standard' => DEST_ZIPS.values

desc "-"
task 'zip:portable' => DEST_ZIPS_PORTABLE.values

PLATFORMS.each do |platform|
	desc "-"
	task "zip:standard:#{platform}" => DEST_ZIPS[platform]

	desc "-"
	task "zip:portable:#{platform}" => DEST_ZIPS_PORTABLE[platform]
end

desc "-"
task :build => RELEASE_EXE.values + RELEASE_PORTABLE_EXE.values

PLATFORMS.each do |platform|
	file DEST_EXES[platform] => [EXEPRESS_INIS[platform], DEST_CABS[platform]] do |task|
		# Exepressでexeを作成
		sh %Q|"#{EXEPRESS}" "#{EXEPRESS_INIS[platform]}"|

		notify "#{task} を作成しました。"
	end
	
	file DEST_CABS[platform] => [DEST_ZIPS[platform]] do |task|
	    # cab形式で再圧縮
	    cab_path = File.expand_path(task.name).gsub('/', '\\')
		cd "out/content" do
			outlines = []
			outlines.push(".Set CabinetNameTemplate=\"#{cab_path}\"")
			outlines.push(".Set DiskDirectoryTemplate=")
			outlines.push(".Set MaxDiskSize=102400000") # サイズ制限は1GB
			outlines.push(".Set CompressionType=LZX")
			outlines.push(".Set CompressionMemory=21")
		
			current_dest_dir = ''
			Dir.glob("#{platform}/**/*") do |path|
				if File.file?(path) then
					dest_dir = File.dirname(path).sub(/^#{platform}\/?/, '').gsub('/', '\\')
					if current_dest_dir != dest_dir then
						outlines.push(%Q|.Set DestinationDir=#{dest_dir}|)
						current_dest_dir = dest_dir
					end
					outlines.push('"' + path.gsub('/', '\\') + '"')
				end
			end
			File.write('cab.ddf', outlines.join("\n"), encoding: 'cp932')
			sh %Q|makecab /F cab.ddf|
		end
	end
	
	ini_path = EXEPRESS_INIS[platform]
	file ini_path => ['InazumaSearch_exepress_template.ini', OUTDIR] do |task|
	    # ExePress用のiniファイルを作成
	    express_enc = 'UTF-16LE'
	    inibody = File.read('InazumaSearch_exepress_template.ini', encoding: express_enc, mode: 'rb')
	    inibody.gsub!('${CHDIR}'.encode(express_enc), Dir.pwd.gsub('/', '\\').encode(express_enc));
	    inibody.gsub!('${VERSION}'.encode(express_enc), version.encode(express_enc));
	    inibody.gsub!('${PLATFORM}'.encode(express_enc), platform.encode(express_enc));
	    inibody.gsub!('${64bitSFX}'.encode(express_enc), (platform == 'x64' ? '1' : '0').encode(express_enc));
	    inibody.gsub!('${TITLE_SUFFIX}'.encode(express_enc), (platform == 'x64' ? '' : ' (32ビット版)').encode(express_enc));
	    inibody.gsub!('${STARTMENU_TITLE_SUFFIX}'.encode(express_enc), (platform == 'x64' ? '' : ' (x86)').encode(express_enc));
	    inibody.gsub!('${UnInstallKey}'.encode(express_enc), (platform == 'x64' ? 'Inazuma Search' : 'Inazuma Search x86').encode(express_enc));
	    File.write(task.name, inibody, encoding: express_enc, mode: 'wb')
	    
	    $stderr.puts "-> #{task.name}"
	end
	
	file DEST_ZIPS[platform] => [RELEASE_EXE[platform]] do |task|
	    # zipファイルを作成
	    make_zip("Release", platform, task.name)

	    # zipファイルの内容を一度展開
	    rm_r "out/content/#{platform}" if File.exist?("out/content/#{platform}")
	    sh %Q|7z x "#{task.name}" -o"out/content/#{platform}" |
	end

	file DEST_ZIPS_PORTABLE[platform] => [RELEASE_PORTABLE_EXE[platform], __FILE__] do |task|
	    # ポータブル版のzipファイルを作成
	    make_portable_zip("Release_Portable", platform, task.name)
	end

	file RELEASE_EXE[platform] => [__FILE__] + SRCS.to_a do
	    # リリース版ビルド
	    sh %Q|"#{MSBUILD}" /maxcpucount /t:Rebuild "/p:Configuration=Release;Platform=#{platform}"|
	end

	file RELEASE_PORTABLE_EXE[platform] => [__FILE__] + SRCS.to_a do
	    # リリース版（Portable）ビルド
	    sh %Q|"#{MSBUILD}" /maxcpucount /t:Rebuild "/p:Configuration=Release (Portable);Platform=#{platform}"|
	end
end

def rmdir_if_exists(path)
    if Dir.exist?(path) then
    	rm_r path
    end
end

desc "-"
task :clean do
    # クリーン
    PLATFORMS.each do |platform|
	    sh %Q|"#{MSBUILD}" /maxcpucount /t:Clean "/p:Configuration=Release;Platform=#{platform}"|
	    sh %Q|"#{MSBUILD}" /maxcpucount /t:Clean "/p:Configuration=Release (Portable);Platform=#{platform}"|
	    
	    if Dir.exist?("InazumaSearch/bin/Release/#{platform}") then
	    	rm_r "InazumaSearch/bin/Release/#{platform}"
	    end

	    if Dir.exist?("InazumaSearch/bin/Release_Portable/#{platform}") then
	    	rm_r "InazumaSearch/bin/Release_Portable/#{platform}"
	    end

	end

	rmdir_if_exists 'out/content'
	rmdir_if_exists 'InazumaSearch/bin'
    rmdir_if_exists 'InazumaSearch/obj'
	rmdir_if_exists 'InazumaSearch_Debug/bin'
    rmdir_if_exists 'InazumaSearch_Debug/obj'
	rmdir_if_exists 'InazumaSearchUnitTest/bin'
    rmdir_if_exists 'InazumaSearchUnitTest/obj'
	rmdir_if_exists 'PluginSDK/bin'
    rmdir_if_exists 'PluginSDK/obj'
	rmdir_if_exists 'portableLaunch/bin'
    rmdir_if_exists 'portableLaunch/obj'
	rmdir_if_exists 'restarter/bin'
    rmdir_if_exists 'restarter/obj'
	rmdir_if_exists 'Tools/bin'
    rmdir_if_exists 'Tools/obj'


    EXEPRESS_INIS.values.each do |ini_path|
    	rm ini_path if File.exist?(ini_path)
    end
end

def make_zip(conf_type, platform, dest_zip_path)
	begin
	    rm dest_zip_path if File.exist?(dest_zip_path)
	    
	    cd "InazumaSearch/bin/#{conf_type}/#{platform}" do
	        mkpath 'plugins'
	        sh %Q|7z a -x!*.pdb -x!data -x!NLog.config -x!GPUCache -x!*.vshost.exe -x!*.vshost.exe.* -x!_DebugExeTemporary -x!locales -x!swiftshader -x!debug.log "../../../../#{dest_zip_path}" .|
	        sh %Q|7z a "../../../../#{dest_zip_path}" InazumaSearch*.pdb|
	        sh %Q|7z a "../../../../#{dest_zip_path}" restart.pdb|
	        sh %Q|7z a "../../../../#{dest_zip_path}" locales/ja.pak|
	    end

	    cd 'InazumaSearch' do
	        sh %Q|7z a "../#{dest_zip_path}" html|
	    end
    rescue
    	rm dest_zip_path if File.exist?(dest_zip_path)
    	raise $!
    end
end

def make_portable_zip(conf_type, platform, dest_zip_path)
	begin
	    rm dest_zip_path if File.exist?(dest_zip_path)
	    cd "InazumaSearch/bin/#{conf_type}/anycpu" do
	    	# exe名リネーム
	    	rm 'InazumaSearchPortable.exe' if File.exist?('InazumaSearchPortable.exe')
	    	cp 'portableLaunch.exe', 'InazumaSearchPortable.exe'
	    end	    
	    
	    cd "InazumaSearch/bin/#{conf_type}/#{platform}" do
	    	# pluginsディレクトリ追加
	        mkpath 'program/plugins'
	        
	        # 圧縮
	        sh %Q|7z a -x!program/*.pdb -x!portableLaunch.exe.config -x!data -x!program/NLog.config -x!program/GPUCache -x!program/*.vshost.exe -x!program/*.vshost.exe.* -x!program/_DebugExeTemporary -x!program/locales/*.pak -x!program/swiftshader -x!program/debug.log "../../../../#{dest_zip_path}" .|
	        sh %Q|7z a "../../../../#{dest_zip_path}" program/InazumaSearch*.pdb|
	        sh %Q|7z a "../../../../#{dest_zip_path}" program/restart.pdb|
	        sh %Q|7z a "../../../../#{dest_zip_path}" ../anycpu/InazumaSearchPortable.exe|
	        sh %Q|7z a "../../../../#{dest_zip_path}" program/locales/ja.pak|
	    end
	   	    
	    
	    # tmpディレクトリを作成し、その中にhtmlフォルダをコピー
	    mkpath 'out/_portable_tmp/program'
	    cp_r 'InazumaSearch/html', 'out/_portable_tmp/program'
	    
	    cd 'out/_portable_tmp' do
	        sh %Q|7z a "../../#{dest_zip_path}" program|
	    end

    rescue
    	rm dest_zip_path if File.exist?(dest_zip_path)
    	raise $!
    ensure
    	begin
    		rm_r 'out/_portable_tmp'
    	rescue
    	end
    end
end

def notify(msg)
	sh %Q|powershell -File "./notify.ps1" "rake (InazumaSearch)" "#{msg}" |
end