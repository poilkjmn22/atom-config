const axios = require("axios");
const cheerio = require("cheerio");
const path = require("path");
const urlencode = require("urlencode");
const { writeFile } = require("fs/promises");
const prettier = require("prettier");

async function getFF14VocationalSkill(filepath) {
  const { data, status } = await axios
    .post(filepath, { timeout: 1 * 60 * 1000 })
    .catch(console.error);
  if (status === 200) {
    const $ = cheerio.load(data);

    const vocationalSkillList = $("#tab-1 table td .item-name a");
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
        const matchPower = $tooltip
          .html()
          .match(/威力：<\/span>(\d+)(?:～(\d+))?/);
        const power = parseInt(matchPower && (matchPower[2] || matchPower[1]));
        const matchMagicCost = $tooltip.text().match(/消耗魔力[:：]?(\d+)/);
        const magicCost = parseInt(matchMagicCost && matchMagicCost[1]);
        skillInfoMap.set(
          skillName,
          Object.assign(si, {
            power,
            magicCost,
          })
        );
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
    return skillInfoMap;
  } else {
    console.log("未获取到html内容!");
  }
}
async function convertSkillData(filepath) {
  // const res = [["技能名称", "威力", "消耗魔法"]];
  const res = [];
  const mapSkillInfo = await getFF14VocationalSkill(filepath);
  for (const [name, { power, magicCost }] of mapSkillInfo) {
    if (power) {
      res.push({ name, power, magicCost });
    }
  }
  try {
    const vocation = urlencode.decode(filepath.match(/\/([^/]+)$/)[1], "utf8");
    await writeFile(
      path.resolve(`./ff14VocationSkill/${vocation}.json`),
      prettier.format(JSON.stringify(res), { semi: true, parser: "json" }),
      { encoding: "utf8" }
    );
  } catch (error) {
    console.error("there was an error:", error.message);
  }
  return res;
}

const skillList = ["钐镰客", "黑魔法师", "武士"];
for (const skill of skillList) {
  convertSkillData(
    `https://ff14.huijiwiki.com/wiki/${urlencode(skill, "utf8")}`
  );
}
