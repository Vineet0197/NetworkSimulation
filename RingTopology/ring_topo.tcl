# Author - Vineet Aggarwal
# Date - 09 April 2022
# Description - Study of Network Simulation tools - This program will create RING Topology with 6 nodes
# and establish TCP Agents between the nodes and create FTP traffic flows between them.
#

# Start new Simulation and set Routing Protocol as Link State (LS)
set ns [new Simulator]
$ns rtproto LS

# Creating the trace file
set tf [open out.tr w]
$ns trace-all $tf
set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam
	exit 0
}

# Creating Nodes for Simulation
for {set idx 0} {$idx<7} {incr idx} {
	set n($idx) [$ns node]
}

# Creating Duplex links to generate ring
for {set idx 0} {$idx<7} {incr idx} {
	$ns duplex-link $n($idx) $n([expr ($idx+1)%7]) 2Mb 10ms DropTail
}

$ns duplex-link-op $n(0) $n(1) queuePos 1
$ns duplex-link-op $n(0) $n(6) queuePos 1

# Creating TCP Agents
# This will attach TCP Agents (using attach-agent) at any two nodes by
# creating source and sink objects and connecting them using connect instance.
set tcp [new Agent/TCP]
$ns attach-agent $n(1) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n(4) $sink
$ns connect $tcp $sink

# Create FTP Traffic and attaching to TCP source
# Creating FTP over TCP
set ftp [new Application/FTP]
$ftp set packetSize_ 1024
$ftp set interval_ 0.5
$ftp attach-agent $tcp

$ns rtmodel-at 0.7 down $n(2) $n(3)
$ns rtmodel-at 2.5 up $n(2) $n(3)

# Start and Stop FTP
$ns at 0.5 "$ftp start"
$ns at 50.5 "$ftp stop"

# Calling procedure to finish after 51 seconds of simulation time
$ns at 51.0 "finish"

# Start the NS2 Simulation
$ns run

output=====
cd /home/ubuntu/
root@ubuntu:~/Vineet/RingTopo$ ns ring_topo.tcl


===================

