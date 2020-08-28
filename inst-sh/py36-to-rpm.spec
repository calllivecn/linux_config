Summary: python3.6.8 package.
Name: python36
Version: 1.0
Release: 1
License: GPL
Group: Development/Tools

Requires: libopenssl1_0_0

# 去除自动依赖
AutoReqProv: no

%description
build python3.6 to Vmware VRO 
 
%prep
%build
 
%install  # 安装阶段
mkdir -p $RPM_BUILD_ROOT/usr/
cp -a /usr/local $RPM_BUILD_ROOT/usr/

#rpm 包含文件
%files
/usr/local/*
