#!/usr/bin/env node
/**
 * VaakKavach - Workflow & Deployment Automation CLI
 * Architect: Mohammad Huzaifa (https://github.com/GuruMachanica)
 */

const { spawnSync } = require('child_process');
const fs = require('fs');

const args = process.argv.slice(2);
const command = args[0] || 'help';

function run(cmd, cmdArgs) {
  const fullCmd = [cmd, ...cmdArgs].join(' ');
  console.log(`\x1b[36m▶ Running:\x1b[0m ${fullCmd}`);
  const res = spawnSync(fullCmd, { stdio: 'inherit', shell: true });
  if (res.status !== 0) {
    console.error(`\x1b[31m✖ Failed with exit code ${res.status}\x1b[0m`);
    process.exit(res.status || 1);
  }
}

switch (command) {
  case 'deploy-website': {
    const isProd = args.includes('--prod') || !args.includes('--preview');
    console.log(`\x1b[32m🚀 Deploying website to Netlify (${isProd ? 'Production' : 'Preview'})...\x1b[0m`);
    if (!fs.existsSync('website/index.html')) {
      console.error('\x1b[31m✖ Error: website directory missing index.html\x1b[0m');
      process.exit(1);
    }
    const netlifyArgs = ['--yes', 'netlify-cli', 'deploy', '--dir=website', '--no-build', '--site-name=vaakkavach-defense'];
    if (isProd) netlifyArgs.push('--prod');
    run('npx', netlifyArgs);
    console.log('\x1b[32m✔ Website deployment sequence complete.\x1b[0m');
    break;
  }

  case 'build-app': {
    console.log('\x1b[32m📱 Compiling VaakKavach Release APK...\x1b[0m');
    run('flutter', ['build', 'apk', '--release']);
    console.log('\x1b[32m✔ Release APK generated in build/app/outputs/flutter-apk/app-release.apk\x1b[0m');
    break;
  }

  case 'release-app': {
    const version = args[1];
    if (!version) {
      console.error('\x1b[31m✖ Usage: node bin/workflow_cli.js release-app <vX.Y.Z>\x1b[0m');
      process.exit(1);
    }
    console.log(`\x1b[32m🏷️ Preparing release tag ${version}...\x1b[0m`);
    run('git', ['tag', '-a', version, '-m', `Release ${version} • VaakKavach Autonomous Shield`]);
    run('git', ['push', 'origin', version]);
    console.log(`\x1b[32m✔ Tag ${version} pushed! GitHub Actions release workflow triggered.\x1b[0m`);
    break;
  }

  case 'status': {
    console.log('\x1b[33m=== VaakKavach System & Deployment Status ===\x1b[0m');
    run('git', ['status', '-s']);
    console.log('\x1b[36mRemote:\x1b[0m');
    run('git', ['remote', '-v']);
    console.log('\x1b[36mRecent Commits:\x1b[0m');
    run('git', ['log', '-n', '2', '--oneline']);
    break;
  }

  default:
    console.log(`
\x1b[32mVaakKavach (वाक्कवच) Workflow CLI\x1b[0m
Author: Mohammad Huzaifa (https://github.com/GuruMachanica)

Usage:
  node bin/workflow_cli.js deploy-website [--prod | --preview]
      Deploys the static website directly to Netlify.

  node bin/workflow_cli.js build-app
      Compiles the Android release APK via Flutter.

  node bin/workflow_cli.js release-app <version>
      Tags git commit (e.g. v2.4.0) and triggers the GitHub Releases build pipeline.

  node bin/workflow_cli.js status
      Displays current git and repository synchronization telemetry.
`);
    break;
}
