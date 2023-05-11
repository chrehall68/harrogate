const { exec, execFile, spawn } = require('child_process');

module.exports = {
    compile: function (project_resource, cb) {
        project_resource.src_directory.is_valid().then(function (valid) {
            if (!valid) {
                throw new ServerError(404, 'Project ' + project_resource.name + ' does not contain any source files');
            }
            return project_resource.src_directory.path;
        }).then(function (src_path) {
            var make_cmd = "make";
            console.log(`command is ${make_cmd}`)
            exec(make_cmd, { "cwd": src_path }, cb)
        })["catch"](function (e) {
            cb(e);
        }).done();
    }
};
