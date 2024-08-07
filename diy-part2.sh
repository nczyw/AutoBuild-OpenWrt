#!/bin/bash
# 移除要替换的包
rm -rf feeds/packages/net/v2ray-geodata

#替换
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}
# 添加passwall2
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/luci-app-passwall2
# 添加应用过滤
git clone  https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
# 添加万能推送
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-pushbot

# 添加测速插件
# git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest

echo "

CONFIG_PACKAGE_luci-app-passwall2=y

CONFIG_PACKAGE_luci-app-pushbot=y

#CONFIG_PACKAGE_luci-app-ssr-plus=n

CONFIG_PACKAGE_luci-app-oaf=y

# 测速插件
# CONFIG_PACKAGE_luci-app-netspeedtest=y

" >> .config 

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
# 修改内核版本
sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=6.6/g' target/linux/x86/Makefile
# 修改默认网关
sed -i 's/255.255.255.0/255.255.252.0/g' package/base-files/files/bin/config_generate
