# Author - Vineet Aggarwal
# Date - 09 April 2022
# Description - This program contains network simulation using STAR Topology with FTP Connection over TCP and CBR agent with UDP.

# Setting new network simulator
set ns  [new Simulator]


# Setting Routing protocol as Distance Vector (DV)
$ns rtproto DV

# Creating trace files
set nf [open out.nam w]
$ns namtrace-all $nf
set tf [open out.tr w]
$ns trace-all $tf

proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam
        exit 0
}

# Creating 6 Nodes        
for {set idx 0} {$idx<7} {incr idx} {
	set n($idx) [$ns node]
}

# Creating Duplex Links
for {set idx 1} {$idx<7} {incr idx} {
	$ns duplex-link $n(0) $n($idx) 2Mb 10ms SFQ
}

# Orienting The nodes
$ns duplex-link-op $n(0) $n(1) orient left-up
$ns duplex-link-op $n(0) $n(2) orient right-up
$ns duplex-link-op $n(0) $n(3) orient right
$ns duplex-link-op $n(0) $n(4) orient right-down
$ns duplex-link-op $n(0) $n(5) orient left-down
$ns duplex-link-op $n(0) $n(6) orient left

# Setting different colors for nam flows
$ns color 0 Blue
$ns color 1 Red
$ns color 2 Green
$ns color 3 Yellow

# Creating a TCP agent and attach it to node 1
set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n(1) $tcp

# Creating a TCP Sink agent and attach it to node 4
set sink [new Agent/TCPSink]
$ns attach-agent $n(4) $sink

# Connect both TCP and SINK agent
$ns connect $tcp $sink

# Creating a UDP agent and attach it to node 2
set udp [new Agent/UDP]
$udp set class_ 2
$ns attach-agent $n(2) $udp

# Creating a null agent and attach it to node 5
set null0 [new Agent/Null]
$ns attach-agent $n(5) $null0

# Connect both UDP and NULL agents
$ns connect $udp $null0

# CBR
set cbr [new Application/Traffic/CBR]
$cbr set rate_ 0.25Mb
$cbr attach-agent $udp

# Creating FTP Connection over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp


# Scheduling Events
$ns rtmodel-at 0.5 down $n(0) $n(5)
$ns rtmodel-at 0.9 up $n(0) $n(5)

$ns rtmodel-at 0.7 down $n(0) $n(4)
$ns rtmodel-at 1.2 up $n(0) $n(4)

# Start and Stop FTP Connection
$ns at 0.1 "$ftp start"
$ns at 1.5 "$ftp stop"

# Start and Stop CBR
$ns at 0.2 "$cbr start"
$ns at 1.3 "$cbr stop"

# Call a finish procedure to stop simulation after 2 seconds
$ns at 2.0 "finish"

# Start a Network Simulation
$ns run
