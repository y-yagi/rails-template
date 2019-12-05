require "json"

source_paths.unshift(File.dirname(__FILE__))

run "mv app/assets app/frontend"
run "mkdir app/assets"
run "mv app/frontend/config app/assets/config"

run "mv app/javascript/* app/frontend"
run "rm -rf app/javascript"
apply "config/template.rb"
apply "app/template.rb"

# Javascript code linting and formatting
run "yarn add --dev eslint eslint-plugin-prettier eslint-config-prettier eslint-plugin-eslint-comments eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y prettier"
copy_file ".eslintrc.js"
copy_file ".prettierrc"
copy_file ".eslintignore"
copy_file ".prettierignore"
run "./node_modules/.bin/eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx --fix"

package_json = JSON.parse(File.read("./package.json"))
package_json["scripts"] = {
  "js-lint" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx",
  "js-lint-fix" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx --fix",
  "format-check" => "prettier --check './**/*.{css,scss,json,md,js,ts,tsx,jsx}'",
  "format-fix" => "prettier --write './**/*.{css,scss,json,md,js,ts,tsx,jsx}'"
}
File.write("./package.json", JSON.generate(package_json))

append_to_file "bin/ci-test-pipeline-1" do
  <<~ESLINT

  echo "* ******************************************************"
  echo "* Running JS linting"
  echo "* ******************************************************"
  yarn run js-lint
  ESLINT
end

append_to_file "bin/ci-test-pipeline-1" do
  <<~PRETTIER

  echo "* ******************************************************"
  echo "* Running JS linting"
  echo "* ******************************************************"
  yarn run format-check
  PRETTIER
end

# SASS Linting
run "yarn add --dev sass-lint"

copy_file "bin/sass-lint"
chmod "bin/sass-lint", "+x"
copy_file "sass-lint.yml", ".sass-lint.yml"
append_to_file "bin/ci-test-pipeline-1" do
  <<~SASSLINT

  echo "* ******************************************************"
  echo "* Running SCSS linting"
  echo "* ******************************************************"
  ./bin/sass-lint
  SASSLINT
end
