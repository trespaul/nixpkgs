{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  bc,
}:

stdenv.mkDerivation {
  pname = "rtl8723bu";
  version = "${kernel.version}-unstable-2025-12-14";

  src = fetchFromGitHub {
    owner = "Benetti-Engineering";
    repo = "rtl8723bu";
    rev = "ac3d2f564bdf6816f1e3a3384524dc1a966f78a3";
    sha256 = "sha256-QgmSdxwZiaSH4lG5uafkb+8eRi6ZlTf9kEXufh/I1Co=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = [ bc ] ++ kernel.moduleBuildDependencies;

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "INSTALL_MOD_PATH=$(out)"
    "MODDESTDIR=kernel/net/wireless"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace-quiet /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace-quiet "/sbin/depmod" "#"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Linux driver for RTL8723BU";
    homepage = "https://github.com/Benetti-Engineering/rtl8723bu";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ trespaul ];
    broken = kernel.kernelAtLeast "7.0";
  };
}
