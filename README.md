## 레일스 어플리케이션 템플릿 파일 모음

### 사용법

```bash
$ rails new app_name -m template_file
```

또는 기존의 프로젝트에 적용할 때는 아래와 같이 rake task를 사용할 수 있다.

```bash
$ bin/rake rails:template LOCATION=/path/to/template_file
```

### 1. minitest_template.rb

: guard를 이용한 minitest 자동화를 위한 템플릿

### 2. devise_auth_template.rb

* Gemfile : bootstrap, font-awesome-rails, simple_form, devise, rolify, authority
* Helpers : flash_class, alert_box, flash_box
* MiniTest automation : guard
* Welcome controller generated
* Root route set to welcome#index
* Application layout file updated

> **Note** : rolify and authority should be set up. You can use `fa_icon()` and `fa_stacked_icon()` with font-awesome-rails gem installed.

