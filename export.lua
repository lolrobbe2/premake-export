local p = premake

p.modules.export = {}
p.modules.export._VERSION = p._VERSION

local export = p.modules.export

export.workspace = {}
local workspace = export.workspace

export.project = {}
local project = export.project

export.config = {}
local config = export.config

export.elements = {}

--#region WORKSPACE
export.elements.workspace = function(wks)
	return {
		workspace.workspace,
		workspace.configurations,
		workspace.location,
		workspace.architecture,
		workspace.workspaceTail
	}
end
function export.prepareWorkspace(wks)
	-- set the default location
	wks.location_backup = wks.location
	wks.location = "export/workspaces"
end

function export.generateWorkspace(wks)
	p.eol("\r\n")
	p.indent("  ")
	p.generate(wks, ".json", workspace.generate)
end

function export.generateProject(prj)
	p.eol("\r\n")
	p.indent("  ")
	print("hello")
	p.generate(prj, ".json", project.generate)
end

function workspace.generate(wks)
	export.prepareWorkspace(wks)
	p.callArray(export.elements.workspace, wks)
end

function workspace.workspace(wks)
	p.w('{')
	p.indent("  ", 1)
	p.w('"name":"%s",', wks.name)
end

function workspace.configurations(wks)
	p.w('"configurations":["%s"],', table.concat(workspace.getconfigs(wks), '","'))
end

function workspace.location(wks)
	p.w('"location": "%s",', path.getrelative(os.getcwd(), wks.location_backup))
end

function workspace.architecture(wks)
	p.w('"architecture": "%s"', wks.architecture)
end

function workspace.workspaceTail(wks)
	p.indent("  ", 0)
	p.w('}')
end

--#endregion workspace

--#region PROJECT
export.elements.project = function(prj)
	return {
		project.project,
		project.kind,
		project.language,
		project.config,
		project.projectTail
	}
end

function export.prepareProject(prj)
	-- set the default location
	prj.location_backup = prj.location
	prj.location = "export/projects"
end

function project.generate(prj)
	export.prepareProject(prj)
	p.callArray(export.elements.project, prj)
end

function project.prop(prj, key)
	p.w('"%s":"%s",', key, prj[key])
end

function project.project(prj)
	p.w('{')
	p.indent("  ", 1)
	project.prop(prj, "name")
end

function project.kind(prj)
	project.prop(prj, "kind")
end

function project.language(prj)
	project.prop(prj, "language")
end



function project.config(prj)
	p.w('"configurations":')
	p.indent("  ", 2)
	p.w('{')

	for cfg in p.project.eachconfig(prj) do
		p.callArray(export.elements.config, cfg)
	end
	p.indent("  ", 2)
	p.w('}')
end

function project.projectTail(prj)
	p.indent("  ", 0)
	p.w('}')
end

--#endregion
--#region CONFIG

export.elements.config = function(cfg)
	return {
		config.config,
		config.files,
		config.configTail,
	}
end


function config.config(cfg)
	p.indent("  ", 3)
	p.w('"%s":{', cfg["buildcfg"])
	p.indent("  ", 4)
end
function config.files(cfg)
	local fileConfigs = config.fileConfigs(cfg)
	for _, fcfg in ipairs(fileConfigs) do
		print(fcfg.path)
	end
end
function config.configTail(cfg)
	p.indent("  ", 3)
	p.w('},')
end

--#region UTILS
function workspace.getconfigs(wks)
	local cfgs = {}
	for cfg in p.workspace.eachconfig(wks) do
		table.insert(cfgs, cfg.buildcfg)
	end
	return cfgs
end
function project.getconfigs(prj)
	local cfgs = {}
	for cfg in p.project.eachconfig(prj) do
		table.insert(cfgs, cfg.buildcfg)
	end
	return cfgs
end
function config.fileConfigs(cfg)
	local fconfigs = {}
	local tr       = p.project.getsourcetree(cfg.project)
	if #tr.children > 0 then
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg then
					table.insert(fconfigs, fcfg)
				end
			end
		})
	end
	return fconfigs;
end

--#endregion

newaction {
	trigger = "export",
	shortname = "premake5 export module",
	description = "export workspace properties to json, xml",
	onWorkspace = function(wks)
		export.generateWorkspace(wks)
	end,
	onProject = function(prj)
		export.generateProject(prj)
	end
}
