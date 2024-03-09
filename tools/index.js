const axios = require("axios");
const cheerio = require("cheerio");
const path = require("path");
const urlencode = require("urlencode");
const { writeFile, rm, mkdir } = require("fs/promises");
const prettier = require("prettier");

async function getFF14VocationalSkill(filepath) {
  const { data, status } = await axios
    .post(filepath, { timeout: 1 * 60 * 1000 })
    .catch(console.error);
  if (status === 200) {
    const $ = cheerio.load(data);

    const [vocationalSkillListWrapper] = $("#tab-1");
    const vocationalSkillList = cheerio.load(
      $(vocationalSkillListWrapper).html()
    )("table td .item-name a");

    const skillInfoMap = new Map();
    for (const skill of vocationalSkillList) {
      const $skill = $(skill);
      const baseinfo = $skill.html();
      const skillName = baseinfo.split("<br>")[0];
      skillInfoMap.set(skillName, {
        id: $skill.attr("href").match(/:(\d+)/)[1],
      });
    }
    // console.log(skillInfoMap);
    for (const [skillName, si] of skillInfoMap) {
      const tooltipData = await getSkillTooltip(si.id);
      try {
        const $tooltip = cheerio.load(tooltipData.parse.text["*"]);
        const skillFeatures = extractFeatures($tooltip);
        skillInfoMap.set(skillName, Object.assign(si, skillFeatures));
      } catch (e) {
        console.error(e);
      }
      // break;
    }
    // console.log(skillInfoMap);
    async function getSkillTooltip(id) {
      const { status, data } = await axios
        .get("https://ff14.huijiwiki.com/api.php", {
          params: {
            format: "json",
            action: "parse",
            disablelimitreport: true,
            prop: "text",
            title: "首页",
            smaxage: 86400,
            maxage: 86400,
            text: `{{ActionTooltip/Show|${id}}}`,
          },
        })
        .catch(console.error);
      if (status === 200) {
        return data;
      }
      return null;
    }
    function extractFeatures($tooltip) {
      const matchPower = $tooltip
        .html()
        .match(/威力：<\/span>(\d+)(?:～(\d+))?/g);
      const matchPowerMax = matchPower && matchPower[matchPower.length - 1];
      const power = parseInt(matchPowerMax && matchPowerMax.match(/\d+$/)[0]);

      const matchMagicCost = $tooltip.text().match(/消耗魔力[:：]?(\d+)/);
      const magicCost = parseInt(matchMagicCost && matchMagicCost[1]);

      const matchDistance = $tooltip.text().match(/距离[:：]?(\d+)/);
      const distance = parseInt(matchDistance && matchDistance[1]);

      const matchAttackRange = $tooltip.text().match(/范围[:：]?(\d+)/);
      const attackRange = parseInt(matchAttackRange && matchAttackRange[1]);

      const matchCD = $tooltip.text().match(/复唱时间[:：]?(\d+(?:\.\d+)?)/);
      const CD = parseFloat(matchCD && matchCD[1]);
      return { power, magicCost, distance, attackRange, CD };
    }
    return skillInfoMap;
  } else {
    console.log("未获取到html内容!");
  }
}
const baseDir = "./ff14VocationSkill";
const skillList = [
  "钐镰客",
  "黑魔法师",
  "武士",
  "吟游诗人",
  "武僧",
  "忍者",
  "机工士",
  // "舞者",
  // "龙骑士",
];
async function writeSkillInfo(vocation, mapSkillInfo) {
  // const res = [["技能名称", "威力", "消耗魔法"]];
  const res = [];
  for (const [name, skillInfo] of mapSkillInfo) {
    res.push(Object.assign({ name }, skillInfo));
  }
  try {
    await writeFile(
      path.resolve(`${baseDir}/${vocation}.json`),
      prettier.format(JSON.stringify(res), { semi: true, parser: "json" }),
      { encoding: "utf8" }
    );
  } catch (error) {
    console.error("there was an error:", error.message);
  }
  return res;
}

async function loadAllSkill(skillList) {
  const mapSkillInfoList = new Map();
  for (const skill of skillList) {
    const mapSkillInfo = await getFF14VocationalSkill(
      `https://ff14.huijiwiki.com/wiki/${urlencode(skill, "utf8")}`
    );
    mapSkillInfoList.set(skill, mapSkillInfo);
  }
  return mapSkillInfoList;
}

loadAllSkill(skillList)
  .then(async (res) => {
    await rm(baseDir, {
      recursive: true,
      force: true,
    });
    await mkdir(baseDir);
    for (const [vocation, mapSkillInfo] of res) {
      writeSkillInfo(vocation, mapSkillInfo);
    }
    return res;
  })
  .then(async (res) => {
    const data = [];
    const vocationList = ["武士", "钐镰客", "黑魔法师"];
    for (const [vocation, mapSkillInfo] of res) {
      if (!vocationList.includes(vocation)) {
        continue;
      }
      for (const [name, skillInfo] of mapSkillInfo) {
        data.push(Object.assign({ vocation, name }, skillInfo));
      }
    }
    try {
      await writeFile(
        path.resolve(`./ff14VocationSkill/${vocationList.join("&")}.json`),
        prettier.format(JSON.stringify(data), { semi: true, parser: "json" }),
        { encoding: "utf8" }
      );
    } catch (error) {
      console.error("there was an error:", error.message);
    }
  });
