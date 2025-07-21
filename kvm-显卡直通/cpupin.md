  <vcpu placement='static'>12</vcpu>
  <cputune>
    <vcpupin vcpu='0' cpuset='0,8'/>
    <vcpupin vcpu='1' cpuset='1,9'/>
    <vcpupin vcpu='2' cpuset='2,10'/>
    <vcpupin vcpu='3' cpuset='3,11'/>
    <vcpupin vcpu='4' cpuset='4,12'/>
    <vcpupin vcpu='5' cpuset='5,13'/>
    <vcpupin vcpu='6' cpuset='0,8'/>
    <vcpupin vcpu='7' cpuset='1,9'/>
    <vcpupin vcpu='8' cpuset='2,10'/>
    <vcpupin vcpu='9' cpuset='3,11'/>
    <vcpupin vcpu='10' cpuset='4,12'/>
    <vcpupin vcpu='11' cpuset='5,13'/>
    <emulatorpin cpuset='6-7,14-15'/>
  </cputune>
 ...
   <cpu mode='host-passthrough' check='partial' migratable='on'>
    <topology sockets='1' dies='1' cores='6' threads='2'/>
  </cpu>
