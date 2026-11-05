# Developer Workstation

## 1. 프로젝트 개요

Linux CLI, Docker, Git/GitHub를 이용하여
재현 가능한 개발 워크스테이션을 구축합니다.

NGINX 웹 서버를 커스텀 Docker 이미지로 만들고,
포트 매핑, 바인드 마운트, 볼륨 영속성을 검증합니다.

## 2. 실행 환경

- OS: [실제 OS 및 버전]
- Shell: [실제 Shell]
- Terminal: [사용 터미널]
- Docker: [실제 버전]
- Git: [실제 버전]
- Container Runtime: OrbStack

## 3. 수행 체크리스트

- [ ] 터미널 기본 조작
- [ ] 파일 및 디렉토리 권한
- [ ] Docker 설치 및 엔진 점검
- [ ] hello-world, Ubuntu 컨테이너
- [ ] Dockerfile 기반 커스텀 이미지
- [ ] 포트 8080/8081 접속
- [ ] 바인드 마운트 변경 반영
- [ ] Docker 볼륨 데이터 영속성
- [ ] Git/GitHub 및 VS Code 연동
- [ ] 트러블슈팅 2건 이상

## 4. 프로젝트 구성

- Dockerfile: NGINX 기반 커스텀 이미지
- site/: 정적 HTML 웹페이지
- practice/: 터미널과 파일 권한 실습
- logs/: 실제 명령어 및 실행 결과
- evidence/: 스크린샷 증거

## 5. 빌드 및 실행 방법

### Docker 이미지 빌드

    docker build -t workshop-web:1.0 .

### 컨테이너 실행

    docker run -d \
      --name workshop-web-8080 \
      -p 127.0.0.1:8080:80 \
      workshop-web:1.0

### 접속 확인

    curl -i http://127.0.0.1:8080

브라우저 접속: http://127.0.0.1:8080

## 6. 수행 로그 및 증거

| 검증 항목 | 결과 파일 |
|---|---|
| CLI 기본 조작 | [로그](logs/01-cli.txt) |
| 권한 변경 | [로그](logs/02-permissions.txt) |
| Docker 점검 | [로그](logs/03-docker.txt) |
| 웹 서버 실행 | [로그](logs/04-web.txt) |
| 바인드 마운트 | [로그](logs/05-bind.txt) |
| 볼륨 영속성 | [로그](logs/06-volume.txt) |
| Git 연동 | [로그](logs/07-git.txt) |
| 트러블슈팅 | [로그](logs/08-troubleshooting.txt) |

### 포트 매핑 결과

검증 명령: curl -i http://127.0.0.1:8080

검증 결과: [실제 HTTP 응답과 실행 결과 기입]

![8080 접속](evidence/web-8080.png)

![8081 접속](evidence/web-8081.png)

### 바인드 마운트

![변경 전](evidence/bind-before.png)

![변경 후](evidence/bind-after.png)

### VS Code / GitHub

![GitHub 연동](evidence/vscode-github.png)

## 7. 트러블슈팅

### 사례 1

- 문제: [실제 오류]
- 원인 가설: [가설]
- 확인 명령: [명령]
- 확인 결과: [실제 출력]
- 해결: [조치]
- 검증 결과: [재실행 결과]

### 사례 2

- 문제:
- 원인 가설:
- 확인 명령:
- 확인 결과:
- 해결:
- 검증 결과:

## 8. 학습 내용

- 이미지와 컨테이너의 차이
- 파일 권한 755와 644
- 절대 경로와 상대 경로
- 포트 매핑의 필요성
- 바인드 마운트와 볼륨의 차이
- Git과 GitHub의 차이

## 9. 재현 및 주의사항

- OrbStack 또는 Docker 엔진이 실행 중이어야 합니다.
- 사용 중인 포트라면 다른 호스트 포트를 지정합니다.
- 바인드 마운트는 프로젝트의 실제 절대 경로를 사용합니다.
- 토큰, 개인키, 비밀번호는 커밋하지 않습니다.
