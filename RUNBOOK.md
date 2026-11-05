# 런북: 개발 워크스테이션 재현

이 문서의 명령을 위에서 아래로 실행하면 `logs/`의 모든 로그와 컨테이너 구성이 다시 만들어집니다. 같은 터미널 세션에서 끝까지 이어서 실행합니다.

컨테이너 ID, 시각, 이미지 크기, 사용자 경로처럼 실행마다 달라지는 값을 제외하면 결과는 같습니다.

## 0. 준비

| 항목 | 이 저장소에서 사용한 값 |
|---|---|
| OS | macOS 15.4.1 (Apple Silicon) |
| Shell | zsh 5.9 |
| Container Runtime | Docker Desktop (Docker 29.6.1) |
| Git | 2.39.5 |
| 추가 도구 | `curl`, `expect`, `perl` (macOS 기본 포함), `gh` (GitHub 연동 확인용) |

Docker Desktop을 실행하고, 저장소를 내려받아 그 루트로 이동합니다.

```text
git clone https://github.com/doji-kr/codyssey-daejeon.git
cd codyssey-daejeon
```

Git 사용자 정보가 없다면 본인 값으로 설정합니다. 값이 이미 있으면 건너뜁니다.

```text
git config --global user.name "<이름>"
git config --global user.email "<이메일>"
git config --global init.defaultBranch main
```

주의사항:

- 8080, 8081, 8082, 8099, 8100 포트가 비어 있어야 합니다. 사용 중이면 명령의 호스트 포트를 바꿉니다.
- 다른 OS에서는 `expect`를 설치해야 합니다. Docker Desktop이 아니면 3단계의 런타임 표시가 달라집니다.
- 바인드 마운트는 `$PWD`를 사용하므로 저장소 위치에 상관없이 동작합니다. 저장소 경로가 Docker Desktop의 File Sharing 범위 안에 있어야 합니다.

## 1. 기록 도구 준비 및 초기화

`rec`는 명령과 출력을 현재 로그 파일에 함께 기록합니다. `reset`은 이름이 `workshop-`인 컨테이너와 `workshop-data` 볼륨만 삭제하며, 다른 컨테이너는 건드리지 않습니다.

```zsh
ROOT="$PWD"
export DOCKER_CLI_HINTS=false
begin_log() { LOG="$ROOT/logs/$1"; : > "$LOG"; }
rec() { printf '$ %s\n' "$1" >> "$LOG"; eval "$1" >> "$LOG" 2>&1; }

for id in $(docker ps -aq --filter name=workshop-); do docker rm -f "$id" > /dev/null; done
docker volume rm workshop-data > /dev/null 2>&1
mkdir -p logs
```

## 2. 터미널 조작 (`logs/01-cli.txt`)

현재 위치, 숨김 파일 목록, 상대·절대 경로 이동, 생성, 복사, 이름 변경, 삭제, 내용 확인, 빈 파일 생성을 수행합니다.

```zsh
begin_log 01-cli.txt
rec 'pwd'
rec 'ls -la'
rec 'mkdir -p practice/demo'
rec 'cd practice/demo'
rec 'pwd'
rec 'cd ../..'
rec 'pwd'
rec 'cd "$ROOT/practice"'
rec 'pwd'
rec 'cd ..'
rec 'printf "Hello, Linux CLI\n" > practice/demo/note.txt'
rec 'touch practice/demo/empty.txt'
rec 'cp practice/demo/note.txt practice/demo/copy.txt'
rec 'ls -la practice/demo'
rec 'mv practice/demo/copy.txt practice/demo/renamed.txt'
rec 'cat practice/demo/renamed.txt'
rec 'rm practice/demo/empty.txt'
rec 'ls -la practice/demo'
```

## 3. 권한 실습 (`logs/02-permissions.txt`)

파일과 디렉토리의 권한을 바꾸고 전후를 비교한 뒤 원래 값으로 되돌립니다.

```zsh
begin_log 02-permissions.txt
rec 'ls -l practice/demo/note.txt'
rec 'chmod 600 practice/demo/note.txt'
rec 'ls -l practice/demo/note.txt'
rec 'chmod 644 practice/demo/note.txt'
rec 'ls -l practice/demo/note.txt'
rec 'ls -ld practice/demo'
rec 'chmod 700 practice/demo'
rec 'ls -ld practice/demo'
rec 'chmod 755 practice/demo'
rec 'ls -ld practice/demo'
```

## 4. Docker 점검과 컨테이너 실습 (`logs/03-docker.txt`)

공개 저장소에 다른 프로젝트 정보가 남지 않도록 `docker info`, `docker images`, `docker ps -a`의 출력을 이번 실습 항목으로 한정합니다.

대화형 단계는 `scripts/tty.exp`가 실제 TTY에서 입력을 대신 보냅니다. 직접 입력해도 결과는 같습니다. `TERM=dumb`는 로그에 제어 문자가 섞이지 않게 합니다.

```zsh
begin_log 03-docker.txt
rec 'docker --version'
rec 'docker context show'
rec 'docker info --format "Server Version: {{.ServerVersion}} | Operating System: {{.OperatingSystem}} | OSType: {{.OSType}} | Architecture: {{.Architecture}} | CPUs: {{.NCPU}}"'
rec 'docker pull nginx:stable-alpine'
rec 'docker pull ubuntu:24.04'
rec 'docker run --rm hello-world'
rec 'docker images --filter reference=nginx:stable-alpine --filter reference=ubuntu:24.04 --filter reference=hello-world:latest'
rec 'expect scripts/tty.exp "docker run -it -e TERM=dumb --name workshop-ubuntu-once ubuntu:24.04 bash" "ls" "echo hello from ubuntu" "exit"'
rec 'docker ps -a --filter name=workshop-ubuntu --format "table {{.Names}}\t{{.Status}}"'
rec 'docker run -dit -e TERM=dumb --name workshop-ubuntu ubuntu:24.04 bash'
rec 'expect scripts/tty.exp "docker exec -it -e TERM=dumb workshop-ubuntu bash" "echo inside exec" "exit"'
rec 'docker ps -a --filter name=workshop-ubuntu --format "table {{.Names}}\t{{.Status}}"'
rec 'expect scripts/tty.exp "docker attach workshop-ubuntu" "echo inside attach" "^P^Q"'
rec 'docker ps -a --filter name=workshop-ubuntu --format "table {{.Names}}\t{{.Status}}"'
rec 'expect scripts/tty.exp "docker attach workshop-ubuntu" "exit"'
rec 'docker ps -a --filter name=workshop-ubuntu --format "table {{.Names}}\t{{.Status}}"'
rec 'docker rm workshop-ubuntu-once workshop-ubuntu'
perl -i -pe 's/\r//g; s/^ +(root@)/$1/' "$LOG"
```

기대 결과:

- `exit`로 끝낸 `workshop-ubuntu-once`는 `Exited (0)`입니다.
- `exec` 셸을 종료해도 `workshop-ubuntu`는 `Up`입니다.
- `attach`에서 Ctrl+P, Ctrl+Q로 빠져나오면 `Up`이고, `exit`하면 `Exited (0)`입니다.

## 5. 커스텀 이미지와 포트 매핑 (`logs/04-web.txt`)

```zsh
begin_log 04-web.txt
rec 'docker build --progress=plain -t workshop-web:1.0 .'
rec 'docker images workshop-web:1.0'
rec 'docker inspect --format "{{index .Config.Labels \"org.opencontainers.image.title\"}}" workshop-web:1.0'
rec 'docker run -d --name workshop-web-8080 -p 127.0.0.1:8080:80 workshop-web:1.0'
rec 'docker run -d --name workshop-web-8081 -p 127.0.0.1:8081:80 workshop-web:1.0'
sleep 2
rec 'docker ps --filter name=workshop-web'
rec 'curl -i -s http://127.0.0.1:8080'
rec 'curl -i -s http://127.0.0.1:8081'
rec 'docker exec workshop-web-8080 cat /usr/share/nginx/html/index.html'
rec 'docker logs workshop-web-8080'
rec 'docker stats --no-stream workshop-web-8080 workshop-web-8081'
rec 'docker stop workshop-web-8081'
rec 'docker ps -a --filter name=workshop-web-8081'
rec 'curl -s -S --max-time 3 http://127.0.0.1:8081'
rec 'docker start workshop-web-8081'
sleep 2
rec 'curl -s http://127.0.0.1:8081'
perl -i -pe 's/\r//g' "$LOG"
```

기대 결과: 두 포트 모두 `HTTP/1.1 200 OK`와 `hello, world`를 반환합니다. 8081은 중지한 동안 연결에 실패하고, 다시 시작하면 응답합니다.

## 6. 바인드 마운트 (`logs/05-bind.txt`)

`site-live/`는 `.gitignore` 대상이라 clone에 없으므로 여기서 직접 만듭니다. 호스트 파일만 바꾸고 컨테이너는 재시작하지 않습니다.

```zsh
begin_log 05-bind.txt
rec 'mkdir -p site-live'
rec 'cat > site-live/index.html <<"HTML"
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Bind Mount Test</title>
</head>
<body>
    <h1>Bind Mount Updated, <b>**BEFORE!**</b></h1>
    <p>Changed directly on the host.</p>
</body>
</html>
HTML'
rec 'docker run -d --name workshop-bind -p 127.0.0.1:8082:80 --mount type=bind,source="$PWD/site-live",target=/usr/share/nginx/html,readonly workshop-web:1.0'
sleep 2
rec 'curl -s http://127.0.0.1:8082'
rec 'perl -pi -e "s/BEFORE/AFTER/" site-live/index.html'
rec 'grep AFTER site-live/index.html'
rec 'curl -s http://127.0.0.1:8082'
rec 'docker ps --filter name=workshop-bind --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
```

기대 결과: 재빌드나 재시작 없이 응답이 `BEFORE`에서 `AFTER`로 바뀝니다.

## 7. 볼륨 영속성 (`logs/06-volume.txt`)

```zsh
begin_log 06-volume.txt
rec 'docker volume create workshop-data'
rec 'docker volume ls --filter name=workshop-data'
rec 'docker run -d --name workshop-volume-1 --mount type=volume,source=workshop-data,target=/data ubuntu:24.04 sleep infinity'
rec 'docker exec workshop-volume-1 sh -c "echo Docker persistent data! > /data/hello.txt"'
rec 'docker exec workshop-volume-1 cat /data/hello.txt'
rec 'docker rm -f workshop-volume-1'
rec 'docker ps -a --filter name=workshop-volume'
rec 'docker run -d --name workshop-volume-2 --mount type=volume,source=workshop-data,target=/data ubuntu:24.04 sleep infinity'
rec 'docker exec workshop-volume-2 cat /data/hello.txt'
rec 'docker volume inspect workshop-data'
```

기대 결과: 컨테이너를 삭제해도 새 컨테이너에서 `Docker persistent data!`가 그대로 읽힙니다.

## 8. Git과 GitHub 연동 (`logs/07-git.txt`)

이메일은 공개 로그에 남지 않도록 마스킹합니다.

```zsh
begin_log 07-git.txt
rec 'git --version'
rec 'git config --list | sed -E "s/^(user\.email=).*/\1<masked>/"'
rec 'git config init.defaultBranch'
rec 'git branch --show-current'
rec 'git remote -v'
rec 'git ls-remote --heads origin main'
rec 'gh auth status 2>&1 | grep -E "Logged in|protocol"'
rec 'gh repo view --json nameWithOwner,visibility,url,defaultBranchRef'
```

## 9. 트러블슈팅 재현 (`logs/08-troubleshooting.txt`)

사례 1은 `-p` 없이 실행해 접속할 수 없는 경우, 사례 2는 컨테이너 이름이 충돌하는 경우입니다.

```zsh
begin_log 08-troubleshooting.txt
rec 'docker run -d --name workshop-debug-port workshop-web:1.0'
sleep 2
rec 'curl -s -S --max-time 3 http://127.0.0.1:8099'
rec 'docker ps --filter name=workshop-debug-port --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
rec 'docker port workshop-debug-port'
rec 'docker exec workshop-debug-port wget -qO- http://127.0.0.1:80'
rec 'docker rm -f workshop-debug-port'
rec 'docker run -d --name workshop-debug-port -p 127.0.0.1:8099:80 workshop-web:1.0'
sleep 2
rec 'curl -i -s http://127.0.0.1:8099'
rec 'docker run -d --name workshop-debug-port -p 127.0.0.1:8100:80 workshop-web:1.0'
rec 'docker ps -a --filter name=workshop-debug-port --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
rec 'docker rm -f workshop-debug-port'
rec 'docker run -d --name workshop-debug-port -p 127.0.0.1:8100:80 workshop-web:1.0'
sleep 2
rec 'curl -s http://127.0.0.1:8100'
rec 'docker rm -f workshop-debug-port'
perl -i -pe 's/\r//g' "$LOG"
```

## 10. 최종 검증

모든 줄이 `PASS`여야 합니다.

```zsh
check() { if eval "$2" > /dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; fi; }
check "Docker Desktop 런타임" 'docker info --format "{{.OperatingSystem}}" | grep -q "Docker Desktop"'
check "8080 응답" 'curl -s http://127.0.0.1:8080 | grep -q "hello, world"'
check "8081 응답" 'curl -s http://127.0.0.1:8081 | grep -q "hello, world"'
check "바인드 마운트 반영" 'curl -s http://127.0.0.1:8082 | grep -q "AFTER"'
check "볼륨 데이터 유지" 'docker exec workshop-volume-2 cat /data/hello.txt | grep -q "Docker persistent data!"'
check "실습 파일 유지" 'test -f practice/demo/note.txt && test -f practice/demo/renamed.txt && test ! -e practice/demo/empty.txt'
check "로그 8개 생성" 'test $(ls logs/0[1-8]-*.txt | wc -l) -eq 8'
check "이메일 마스킹" '! grep -Eq "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}" logs/07-git.txt'
```

## 11. 스크린샷 (직접 수행)

스크린샷은 브라우저와 VS Code 화면이 필요해서 직접 찍습니다. Chrome에서 `Cmd+Shift+B`로 북마크바를 숨기고, 주소창의 포트와 응답 화면이 함께 보이도록 `Cmd+Shift+4`로 캡처합니다.

| 저장 파일 | 화면 |
|---|---|
| `evidence/web-8080.png` | 주소창에 직접 입력한 `http://127.0.0.1:8080` |
| `evidence/web-8081.png` | 주소창에 직접 입력한 `http://127.0.0.1:8081` |
| `evidence/bind-after.png` | `http://127.0.0.1:8082`의 현재 화면 (`AFTER`) |
| `evidence/bind-before.png` | 아래 명령으로 되돌린 뒤 새로고침한 화면 (`BEFORE`) |
| `evidence/vscode-github.png` | VS Code 왼쪽 아래 계정 메뉴의 GitHub 로그인과 Source Control의 저장소가 함께 보이는 화면 |

`BEFORE` 화면은 다음 명령으로 만들고, 캡처 후 다시 `AFTER`로 되돌립니다.

```text
perl -pi -e "s/AFTER/BEFORE/" site-live/index.html
perl -pi -e "s/BEFORE/AFTER/" site-live/index.html
```

캡처 전에 토큰, 비밀번호, 개인 정보가 화면에 보이지 않는지 확인합니다.

## 12. 정리 (선택)

실습 환경을 지울 때 실행합니다. 이미지와 볼륨까지 삭제하므로 이후 재현하려면 1단계부터 다시 실행합니다.

```text
for id in $(docker ps -aq --filter name=workshop-); do docker rm -f "$id"; done
docker volume rm workshop-data
docker rmi workshop-web:1.0
```
