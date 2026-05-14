# sa2-login-sddm

Sonic Adventure 2 - SDDM Theme (Qt6)

Tema de login para SDDM inspirado na interface de Sonic Adventure 2.
Funcionalidades

    Intro em vídeo (pulável com clique).

    Lock Screen com relógio estilizado "Press Start".

    Jukebox funcional com trilha sonora de SA2.

    Suporte para Qt6 (Ubuntu 24.04+).

## Como instalar:
1. Baixe o arquivo `.tar.gz` na aba [Releases]((https://github.com/Arthur-25/sa2-login-sddm/releases/tag/1.0)).
2. Extraia o conteúdo.
3. Mova a pasta para o diretório de temas do SDDM:
   ```bash
   sudo cp -r sa2-login /usr/share/sddm/themes/
4. Teste o tema
   sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sa2-login

5.Para que o vídeo da intro e a Jukebox funcionem corretamente, instale as dependências do Qt6:

```bash
sudo apt update
sudo apt install qml6-module-qtmultimedia qml6-module-qt5compat
```
   
Se tudo correr bem

No KDE Plasma:

    Abra as Configurações do Sistema.

    Vá em Inicialização e Desligamento -> Tela de Autenticação (SDDM).

    Selecione o Sonic Adventure 2 Login na lista e clique em Aplicar.

    Via Linha de Comando (Qualquer interface):

Se o usuário não usa KDE, ele pode ativar editando o arquivo de configuração:

sudo nano /etc/sddm.conf

E alterar (ou adicionar) a seção:

[Theme]
Current=sa2-login
