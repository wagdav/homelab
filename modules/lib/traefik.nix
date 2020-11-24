let

  domain = "thewagner.home";

in

{
  tagsForHost = host: [
    "traefik.enable=true"
    "traefik.http.routers.${host}.rule=Host(`${host}`) || Host(`${host}.${domain}`)"
    "traefik.http.routers.${host}.middlewares=${host}-canonical-name"
    "traefik.http.middlewares.${host}-canonical-name.redirectregex.permanent=true"
    "traefik.http.middlewares.${host}-canonical-name.redirectregex.regex=^http://${host}/(.*)"
    "traefik.http.middlewares.${host}-canonical-name.redirectregex.replacement=http://${host}.${domain}/\${1}"
  ];
}
