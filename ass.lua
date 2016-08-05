require "os"
require "io"
require "string"

asstimeout = 10
disasstimeout = 10
pingtimes = 10

function exec(s)
	pipe = io.popen(s)
	return pipe:read("*a")
end

function sleep(t)
	exec("choice /D Y /T " .. t)
end

function expect(cmd, pat)
	output = exec(cmd)
	if string.find(output, pat) then
		return true
	else
		return false
	end
end
	
function checkass()
	for _=1,asstimeout do
		if expect("netsh wlan show interface", "已连接") then
			return true
		end
		sleep(1)
	end
	return false
end

function checkdisass()
	for _=1,disasstimeout do
		if not expect("netsh wlan show interface", "已连接") then
			return true
		end
		sleep(1)
	end
	return false
end

function disass()
	exec("netsh wlan disconnect")
	if not checkdisass() then 
		print"dissass timeout"
		os.exit(1)
	else
		print"disass success"
	end
end

function ass(ssid)
	exec("netsh wlan connect name=" .. ssid)
	if not checkass() then 
		print"ass timeout"
		os.exit(1)
	else
		print("ass to " .. ssid)
	end
end

function ping(host)
	for _=1, pingtimes do
		if expect("ping -w 1000 -n 1 " .. host, "已接收 = 1") then
			print("ping " .. host .. " success")
			os.exit(0)
		else
			print(string.format("ping %s %d times fail", host, _))
		end
	end
end

if arg then
	ssid = arg[1]
	host = arg[2] or "baidu.com"
end

repeat
	disass()
	ass(ssid)
	ping(host)
until nil

