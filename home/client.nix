{
  inputs,
  LT,
  ...
}: {
  imports = [inputs.lazyvim.homeManagerModules.default] ++ LT.ls ./common-apps ++ LT.ls ./client-apps;
}
