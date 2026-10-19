{...}: {
  tags = {
    client = "client";
    server = "server";
  };

  # Primary interactive user. Kept in one place so modules don't hardcode it.
  user = "leo";
  userHome = "/home/leo";
}
